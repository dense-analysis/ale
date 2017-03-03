" Author: w0rp <devw0rp@gmail.com>
" Description: Backend execution and job management
"   Executes linters in the background, using NeoVim or Vim 8 jobs

" Stores information for each job including:
"
" linter: The linter dictionary for the job.
" buffer: The buffer number for the job.
" output: The array of lines for the output of the job.
let s:job_info_map = {}

function! ale#engine#ParseVim8ProcessID(job_string) abort
    return matchstr(a:job_string, '\d\+') + 0
endfunction

function! s:GetJobID(job) abort
    if has('nvim')
        "In NeoVim, job values are just IDs.
        return a:job
    endif

    " For Vim 8, the job is a different variable type, and we can parse the
    " process ID from the string.
    return ale#engine#ParseVim8ProcessID(string(a:job))
endfunction

function! ale#engine#InitBufferInfo(buffer) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        " job_list will hold the list of jobs
        " loclist holds the loclist items after all jobs have completed.
        " new_loclist holds loclist items while jobs are being run.
        " temporary_file_list holds temporary files to be cleaned up
        " temporary_directory_list holds temporary directories to be cleaned up
        " history holds a list of previously run commands for this buffer
        let g:ale_buffer_info[a:buffer] = {
        \   'job_list': [],
        \   'loclist': [],
        \   'new_loclist': [],
        \   'temporary_file_list': [],
        \   'temporary_directory_list': [],
        \   'history': [],
        \}
    endif
endfunction

" A map from timer IDs to Vim 8 jobs, for tracking jobs that need to be killed
" with SIGKILL if they don't terminate right away.
let s:job_kill_timers = {}

function! s:KillHandler(timer) abort
    call job_stop(remove(s:job_kill_timers, a:timer), 'kill')
endfunction

function! ale#engine#ClearJob(job) abort
    let l:job_id = s:GetJobID(a:job)
    let l:linter = s:job_info_map[l:job_id].linter

    if has('nvim')
        call jobstop(a:job)
    else
        " We must close the channel for reading the buffer if it is open
        " when stopping a job. Otherwise, we will get errors in the status line.
        if ch_status(job_getchannel(a:job)) ==# 'open'
            call ch_close_in(job_getchannel(a:job))
        endif

        " Ask nicely for the job to stop.
        call job_stop(a:job)

        " If a job doesn't stop immediately, queue a timer which will
        " send SIGKILL to the job, if it's alive by the time the timer ticks.
        if job_status(a:job) ==# 'run'
            let s:job_kill_timers[timer_start(100, function('s:KillHandler'))] = a:job
        endif
    endif

    if has_key(s:job_info_map, l:job_id)
        call remove(s:job_info_map, l:job_id)
    endif
endfunction

function! s:StopPreviousJobs(buffer, linter) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        " Do nothing if we didn't run anything for the buffer.
        return
    endif

    let l:new_job_list = []

    for l:job in g:ale_buffer_info[a:buffer].job_list
        let l:job_id = s:GetJobID(l:job)

        if has_key(s:job_info_map, l:job_id)
        \&& s:job_info_map[l:job_id].linter.name ==# a:linter.name
            " Stop jobs which match the buffer and linter.
            call ale#engine#ClearJob(l:job)
        else
            " Keep other jobs in the list.
            call add(l:new_job_list, l:job)
        endif
    endfor

    " Update the list, removing the previously run job.
    let g:ale_buffer_info[a:buffer].job_list = l:new_job_list
endfunction

function! s:GatherOutputVim(channel, data) abort
    let l:job_id = s:GetJobID(ch_getjob(a:channel))

    if !has_key(s:job_info_map, l:job_id)
        return
    endif

    call add(s:job_info_map[l:job_id].output, a:data)
endfunction

function! s:GatherOutputNeoVim(job, data, event) abort
    let l:job_id = s:GetJobID(a:job)

    if !has_key(s:job_info_map, l:job_id)
        return
    endif

    " Join the lines passed to ale, because Neovim splits them up.
    " a:data is a list of strings, where every item is a new line, except the
    " first one, which is the continuation of the last item passed last time.
    call ale#engine#JoinNeovimOutput(s:job_info_map[l:job_id].output, a:data)
endfunction

function! ale#engine#JoinNeovimOutput(output, data) abort
    if empty(a:output)
        call extend(a:output, a:data)
    else
        " Extend the previous line, which can be continued.
        let a:output[-1] .= get(a:data, 0, '')

        " Add the new lines.
        call extend(a:output, a:data[1:])
    endif
endfunction

" Register a temporary file to be managed with the ALE engine for
" a current job run.
function! ale#engine#ManageFile(buffer, filename) abort
    call add(g:ale_buffer_info[a:buffer].temporary_file_list, a:filename)
endfunction

" Same as the above, but manage an entire directory.
function! ale#engine#ManageDirectory(buffer, directory) abort
    call add(g:ale_buffer_info[a:buffer].temporary_directory_list, a:directory)
endfunction

function! ale#engine#RemoveManagedFiles(buffer) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        return
    endif

    " We can't delete anything in a sandbox, so wait until we escape from
    " it to delete temporary files and directories.
    if ale#util#InSandbox()
        return
    endif

    " Delete files with a call akin to a plan `rm` command.
    for l:filename in g:ale_buffer_info[a:buffer].temporary_file_list
        call delete(l:filename)
    endfor

    let g:ale_buffer_info[a:buffer].temporary_file_list = []

    " Delete directories like `rm -rf`.
    " Directories are handled differently from files, so paths that are
    " intended to be single files can be set up for automatic deletion without
    " accidentally deleting entire directories.
    for l:directory in g:ale_buffer_info[a:buffer].temporary_directory_list
        call delete(l:directory, 'rf')
    endfor

    let g:ale_buffer_info[a:buffer].temporary_directory_list = []
endfunction

function! s:HandleExit(job) abort
    if a:job ==# 'no process'
        " Stop right away when the job is not valid in Vim 8.
        return
    endif

    let l:job_id = s:GetJobID(a:job)

    if !has_key(s:job_info_map, l:job_id)
        return
    endif

    let l:job_info = s:job_info_map[l:job_id]
    let l:linter = l:job_info.linter
    let l:output = l:job_info.output
    let l:buffer = l:job_info.buffer
    let l:next_chain_index = l:job_info.next_chain_index

    " Call the same function for stopping jobs again to clean up the job
    " which just closed.
    call s:StopPreviousJobs(l:buffer, l:linter)

    " Stop here if we land in the handle for a job completing if we're in
    " a sandbox.
    if ale#util#InSandbox()
        return
    endif

    if l:next_chain_index < len(get(l:linter, 'command_chain', []))
        call s:InvokeChain(l:buffer, l:linter, l:next_chain_index, l:output)
        return
    endif

    " Log the output of the command for ALEInfo if we should.
    if g:ale_history_enabled && g:ale_history_log_output
        call ale#history#RememberOutput(l:buffer, l:job_id, l:output[:])
    endif

    let l:linter_loclist = ale#util#GetFunction(l:linter.callback)(l:buffer, l:output)

    " Make some adjustments to the loclists to fix common problems, and also
    " to set default values for loclist items.
    let l:linter_loclist = ale#engine#FixLocList(l:buffer, l:linter, l:linter_loclist)

    " Add the loclist items from the linter.
    call extend(g:ale_buffer_info[l:buffer].new_loclist, l:linter_loclist)

    if !empty(g:ale_buffer_info[l:buffer].job_list)
        " Wait for all jobs to complete before doing anything else.
        return
    endif

    " Automatically remove all managed temporary files and directories
    " now that all jobs have completed.
    call ale#engine#RemoveManagedFiles(l:buffer)

    " Sort the loclist again.
    " We need a sorted list so we can run a binary search against it
    " for efficient lookup of the messages in the cursor handler.
    call sort(g:ale_buffer_info[l:buffer].new_loclist, 'ale#util#LocItemCompare')

    " Now swap the old and new loclists, after we have collected everything
    " and sorted the list again.
    let g:ale_buffer_info[l:buffer].loclist = g:ale_buffer_info[l:buffer].new_loclist
    let g:ale_buffer_info[l:buffer].new_loclist = []

    call ale#engine#SetResults(l:buffer, g:ale_buffer_info[l:buffer].loclist)

    " Call user autocommands. This allows users to hook into ALE's lint cycle.
    silent doautocmd User ALELint
endfunction

function! ale#engine#SetResults(buffer, loclist) abort
    if g:ale_set_quickfix || g:ale_set_loclist
        call ale#list#SetLists(a:loclist)
    endif

    if g:ale_set_signs
        call ale#sign#SetSigns(a:buffer, a:loclist)
    endif

    if exists('*ale#statusline#Update')
        " Don't load/run if not already loaded.
        call ale#statusline#Update(a:buffer, a:loclist)
    endif

    if g:ale_set_highlights
        call ale#highlight#SetHighlights(a:buffer, a:loclist)
    endif

    if g:ale_echo_cursor
        " Try and echo the warning now.
        " This will only do something meaningful if we're in normal mode.
        call ale#cursor#EchoCursorWarning()
    endif
endfunction

function! s:SetExitCode(job, exit_code) abort
    let l:job_id = s:GetJobID(a:job)

    if !has_key(s:job_info_map, l:job_id)
        return
    endif

    let l:buffer = s:job_info_map[l:job_id].buffer

    call ale#history#SetExitCode(l:buffer, l:job_id, a:exit_code)
endfunction

function! s:HandleExitNeoVim(job, exit_code, event) abort
    if g:ale_history_enabled
        call s:SetExitCode(a:job, a:exit_code)
    endif

    call s:HandleExit(a:job)
endfunction

function! s:HandleExitVim(channel) abort
    call s:HandleExit(ch_getjob(a:channel))
endfunction

" Vim returns the exit status with one callback,
" and the channel will close later in another callback.
function! s:HandleExitStatusVim(job, exit_code) abort
    call s:SetExitCode(a:job, a:exit_code)
endfunction

function! ale#engine#FixLocList(buffer, linter, loclist) abort
    let l:new_loclist = []

    " Some errors have line numbers beyond the end of the file,
    " so we need to adjust them so they set the error at the last line
    " of the file instead.
    let l:last_line_number = ale#util#GetLineCount(a:buffer)

    for l:old_item in a:loclist
        " Copy the loclist item with some default values and corrections.
        "
        " line and column numbers will be converted to numbers.
        " The buffer will default to the buffer being checked.
        " The vcol setting will default to 0, a byte index.
        " The error type will default to 'E' for errors.
        " The error number will default to -1.
        "
        " The line number and text are the only required keys.
        "
        " The linter_name will be set on the errors so it can be used in
        " output, filtering, etc..
        let l:item = {
        \   'text': l:old_item.text,
        \   'lnum': str2nr(l:old_item.lnum),
        \   'col': str2nr(get(l:old_item, 'col', 0)),
        \   'bufnr': get(l:old_item, 'bufnr', a:buffer),
        \   'vcol': get(l:old_item, 'vcol', 0),
        \   'type': get(l:old_item, 'type', 'E'),
        \   'nr': get(l:old_item, 'nr', -1),
        \   'linter_name': a:linter.name,
        \}

        if has_key(l:old_item, 'detail')
            let l:item.detail = l:old_item.detail
        endif

        if l:item.lnum == 0
            " When errors appear at line 0, put them at line 1 instead.
            let l:item.lnum = 1
        elseif l:item.lnum > l:last_line_number
            " When errors go beyond the end of the file, put them at the end.
            let l:item.lnum = l:last_line_number
        endif

        call add(l:new_loclist, l:item)
    endfor

    return l:new_loclist
endfunction

" Given part of a command, replace any % with %%, so that no characters in
" the string will be replaced with filenames, etc.
function! ale#engine#EscapeCommandPart(command_part) abort
    return substitute(a:command_part, '%', '%%', 'g')
endfunction

function! s:TemporaryFilename(buffer) abort
    let l:filename = fnamemodify(bufname(a:buffer), ':t')

    if empty(l:filename)
        " If the buffer's filename is empty, create a dummy filename.
        let l:ft = getbufvar(a:buffer, '&filetype')
        let l:filename = 'file' . ale#filetypes#GuessExtension(l:ft)
    endif

    " Create a temporary filename, <temp_dir>/<original_basename>
    " The file itself will not be created by this function.
    return tempname() . (has('win32') ? '\' : '/') . l:filename
endfunction

" Given a command string, replace every...
" %s -> with the current filename
" %t -> with the name of an unused file in a temporary directory
" %% -> with a literal %
function! ale#engine#FormatCommand(buffer, command) abort
    let l:temporary_file = ''
    let l:command = a:command

    " First replace all uses of %%, used for literal percent characters,
    " with an ugly string.
    let l:command = substitute(l:command, '%%', '<<PERCENTS>>', 'g')

    " Replace all %s occurences in the string with the name of the current
    " file.
    if l:command =~# '%s'
        let l:filename = fnamemodify(bufname(a:buffer), ':p')
        let l:command = substitute(l:command, '%s', '\=fnameescape(l:filename)', 'g')
    endif

    if l:command =~# '%t'
        " Create a temporary filename, <temp_dir>/<original_basename>
        " The file itself will not be created by this function.
        let l:temporary_file = s:TemporaryFilename(a:buffer)
        let l:command = substitute(l:command, '%t', '\=fnameescape(l:temporary_file)', 'g')
    endif

    " Finish formatting so %% becomes %.
    let l:command = substitute(l:command, '<<PERCENTS>>', '%', 'g')

    return [l:temporary_file, l:command]
endfunction

function! s:CreateTemporaryFileForJob(buffer, temporary_file) abort
    if empty(a:temporary_file)
        " There is no file, so we didn't create anything.
        return 0
    endif

    let l:temporary_directory = fnamemodify(a:temporary_file, ':h')
    " Create the temporary directory for the file, unreadable by 'other'
    " users.
    call mkdir(l:temporary_directory, '', 0750)
    " Automatically delete the directory later.
    call ale#engine#ManageDirectory(a:buffer, l:temporary_directory)
    " Write the buffer out to a file.
    call writefile(getbufline(a:buffer, 1, '$'), a:temporary_file)

    return 1
endfunction

function! s:RunJob(options) abort
    let l:command = a:options.command
    let l:buffer = a:options.buffer
    let l:linter = a:options.linter
    let l:output_stream = a:options.output_stream
    let l:next_chain_index = a:options.next_chain_index
    let l:read_buffer = a:options.read_buffer

    let [l:temporary_file, l:command] = ale#engine#FormatCommand(l:buffer, l:command)

    if l:read_buffer && empty(l:temporary_file)
        " If we are to send the Vim buffer to a command, we'll do it
        " in the shell. We'll write out the file to a temporary file,
        " and then read it back in, in the shell.
        let l:temporary_file = s:TemporaryFilename(l:buffer)
        let l:command = l:command . ' < ' . fnameescape(l:temporary_file)
    endif

    if s:CreateTemporaryFileForJob(l:buffer, l:temporary_file)
        " If a temporary filename has been formatted in to the command, then
        " we do not need to send the Vim buffer to the command.
        let l:read_buffer = 0
    endif

    if has('nvim')
        if l:output_stream ==# 'stderr'
            " Read from stderr instead of stdout.
            let l:job = jobstart(l:command, {
            \   'on_stderr': function('s:GatherOutputNeoVim'),
            \   'on_exit': function('s:HandleExitNeoVim'),
            \})
        elseif l:output_stream ==# 'both'
            let l:job = jobstart(l:command, {
            \   'on_stdout': function('s:GatherOutputNeoVim'),
            \   'on_stderr': function('s:GatherOutputNeoVim'),
            \   'on_exit': function('s:HandleExitNeoVim'),
            \})
        else
            let l:job = jobstart(l:command, {
            \   'on_stdout': function('s:GatherOutputNeoVim'),
            \   'on_exit': function('s:HandleExitNeoVim'),
            \})
        endif
    else
        let l:job_options = {
        \   'in_mode': 'nl',
        \   'out_mode': 'nl',
        \   'err_mode': 'nl',
        \   'close_cb': function('s:HandleExitVim'),
        \}

        if g:ale_history_enabled
            " We only need to capture the exit status if we are going to
            " save it in the history. Otherwise, we don't care.
            let l:job_options.exit_cb = function('s:HandleExitStatusVim')
        endif

        if l:output_stream ==# 'stderr'
            " Read from stderr instead of stdout.
            let l:job_options.err_cb = function('s:GatherOutputVim')
        elseif l:output_stream ==# 'both'
            " Read from both streams.
            let l:job_options.out_cb = function('s:GatherOutputVim')
            let l:job_options.err_cb = function('s:GatherOutputVim')
        else
            let l:job_options.out_cb = function('s:GatherOutputVim')
        endif

        " The command will be executed in a subshell. This fixes a number of
        " issues, including reading the PATH variables correctly, %PATHEXT%
        " expansion on Windows, etc.
        "
        " NeoVim handles this issue automatically if the command is a String.
        let l:command = has('win32')
        \   ?  'cmd /c ' . l:command
        \   : split(&shell) + split(&shellcmdflag) + [l:command]

        " Vim 8 will read the stdin from the file's buffer.
        let l:job = job_start(l:command, l:job_options)
    endif

    let l:status = 'failed'
    let l:job_id = 0

    " Only proceed if the job is being run.
    if has('nvim') || (l:job !=# 'no process' && job_status(l:job) ==# 'run')
        " Add the job to the list of jobs, so we can track them.
        call add(g:ale_buffer_info[l:buffer].job_list, l:job)

        let l:status = 'started'
        let l:job_id = s:GetJobID(l:job)
        " Store the ID for the job in the map to read back again.
        let s:job_info_map[l:job_id] = {
        \   'linter': l:linter,
        \   'buffer': l:buffer,
        \   'output': [],
        \   'next_chain_index': l:next_chain_index,
        \}
    endif

    if g:ale_history_enabled
        call ale#history#Add(l:buffer, l:status, l:job_id, l:command)
    else
        let g:ale_buffer_info[l:buffer].history = []
    endif
endfunction

" Determine which commands to run for a link in a command chain, or
" just a regular command.
function! ale#engine#ProcessChain(buffer, linter, chain_index, input) abort
    let l:output_stream = get(a:linter, 'output_stream', 'stdout')
    let l:read_buffer = a:linter.read_buffer
    let l:chain_index = a:chain_index
    let l:input = a:input

    if has_key(a:linter, 'command_chain')
        while l:chain_index < len(a:linter.command_chain)
            " Run a chain of commands, one asychronous command after the other,
            " so that many programs can be run in a sequence.
            let l:chain_item = a:linter.command_chain[l:chain_index]

            if l:chain_index == 0
                " The first callback in the chain takes only a buffer number.
                let l:command = ale#util#GetFunction(l:chain_item.callback)(
                \   a:buffer
                \)
            else
                " The second callback in the chain takes some input too.
                let l:command = ale#util#GetFunction(l:chain_item.callback)(
                \   a:buffer,
                \   l:input
                \)
            endif

            if !empty(l:command)
                " We hit a command to run, so we'll execute that

                " The chain item can override the output_stream option.
                if has_key(l:chain_item, 'output_stream')
                    let l:output_stream = l:chain_item.output_stream
                endif

                " The chain item can override the read_buffer option.
                if has_key(l:chain_item, 'read_buffer')
                    let l:read_buffer = l:chain_item.read_buffer
                elseif l:chain_index != len(a:linter.command_chain) - 1
                    " Don't read the buffer for commands besides the last one
                    " in the chain by default.
                    let l:read_buffer = 0
                endif

                break
            endif

            " Command chain items can return an empty string to indicate that
            " a command should be skipped, so we should try the next item
            " with no input.
            let l:input = []
            let l:chain_index += 1
        endwhile
    elseif has_key(a:linter, 'command_callback')
        " If there is a callback for generating a command, call that instead.
        let l:command = ale#util#GetFunction(a:linter.command_callback)(a:buffer)
    else
        let l:command = a:linter.command
    endif

    if empty(l:command)
        " Don't run any jobs if the command is an empty string.
        return {}
    endif

    return {
    \   'command': l:command,
    \   'buffer': a:buffer,
    \   'linter': a:linter,
    \   'output_stream': l:output_stream,
    \   'next_chain_index': l:chain_index + 1,
    \   'read_buffer': l:read_buffer,
    \}
endfunction

function! s:InvokeChain(buffer, linter, chain_index, input) abort
    let l:options = ale#engine#ProcessChain(a:buffer, a:linter, a:chain_index, a:input)

    if !empty(l:options)
        call s:RunJob(l:options)
    elseif empty(g:ale_buffer_info[a:buffer].job_list)
        " If we cancelled running a command, and we have no jobs in progress,
        " then delete the managed temporary files now.
        call ale#engine#RemoveManagedFiles(a:buffer)
    endif
endfunction

function! ale#engine#Invoke(buffer, linter) abort
    " Stop previous jobs for the same linter.
    call s:StopPreviousJobs(a:buffer, a:linter)
    call s:InvokeChain(a:buffer, a:linter, 0, [])
endfunction

" Given a buffer number, return the warnings and errors for a given buffer.
function! ale#engine#GetLoclist(buffer) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        return []
    endif

    return g:ale_buffer_info[a:buffer].loclist
endfunction

" This function can be called with a timeout to wait for all jobs to finish.
" If the jobs to not finish in the given number of milliseconds,
" an exception will be thrown.
"
" The time taken will be a very rough approximation, and more time may be
" permitted than is specified.
function! ale#engine#WaitForJobs(deadline) abort
    let l:start_time = system('date +%s%3N') + 0

    if l:start_time == 0
        throw 'Failed to read milliseconds from the clock!'
    endif

    let l:job_list = []

    " Gather all of the jobs from every buffer.
    for l:info in values(g:ale_buffer_info)
        call extend(l:job_list, l:info.job_list)
    endfor

    let l:should_wait_more = 1

    while l:should_wait_more
        let l:should_wait_more = 0

        for l:job in l:job_list
            if job_status(l:job) ==# 'run'
                let l:now = system('date +%s%3N') + 0

                if l:now - l:start_time > a:deadline
                    " Stop waiting after a timeout, so we don't wait forever.
                    throw 'Jobs did not complete on time!'
                endif

                " Wait another 10 milliseconds
                let l:should_wait_more = 1
                sleep 10ms
                break
            endif
        endfor
    endwhile

    " Sleep for a small amount of time after all jobs finish.
    " This seems to be enough to let handlers after jobs end run, and
    " prevents the occasional failure where this function exits after jobs
    " end, but before handlers are run.
    sleep 10ms

    " We must check the buffer data again to see if new jobs started
    " for command_chain linters.
    let l:has_new_jobs = 0

    for l:info in values(g:ale_buffer_info)
        if !empty(l:info.job_list)
            let l:has_new_jobs = 1
        endif
    endfor

    if l:has_new_jobs
        " We have to wait more. Offset the timeout by the time taken so far.
        let l:now = system('date +%s%3N') + 0
        let l:new_deadline = a:deadline - (l:now - l:start_time)

        if l:new_deadline <= 0
            " Enough time passed already, so stop immediately.
            throw 'Jobs did not complete on time!'
        endif

        call ale#engine#WaitForJobs(l:new_deadline)
    endif
endfunction
