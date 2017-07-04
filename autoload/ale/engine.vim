" Author: w0rp <devw0rp@gmail.com>
" Description: Backend execution and job management
"   Executes linters in the background, using NeoVim or Vim 8 jobs

" Stores information for each job including:
"
" linter: The linter dictionary for the job.
" buffer: The buffer number for the job.
" output: The array of lines for the output of the job.
if !has_key(s:, 'job_info_map')
    let s:job_info_map = {}
endif

let s:executable_cache_map = {}

" Check if files are executable, and if they are, remember that they are
" for subsequent calls. We'll keep checking until programs can be executed.
function! s:IsExecutable(executable) abort
    if has_key(s:executable_cache_map, a:executable)
        return 1
    endif

    if executable(a:executable)
        let s:executable_cache_map[a:executable] = 1

        return 1
    endif

    return  0
endfunction

function! ale#engine#InitBufferInfo(buffer) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        " job_list will hold the list of jobs
        " loclist holds the loclist items after all jobs have completed.
        " temporary_file_list holds temporary files to be cleaned up
        " temporary_directory_list holds temporary directories to be cleaned up
        " history holds a list of previously run commands for this buffer
        let g:ale_buffer_info[a:buffer] = {
        \   'job_list': [],
        \   'loclist': [],
        \   'temporary_file_list': [],
        \   'temporary_directory_list': [],
        \   'history': [],
        \}
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

" Create a new temporary directory and manage it in one go.
function! ale#engine#CreateDirectory(buffer) abort
    let l:temporary_directory = tempname()
    " Create the temporary directory for the file, unreadable by 'other'
    " users.
    call mkdir(l:temporary_directory, '', 0750)
    call ale#engine#ManageDirectory(a:buffer, l:temporary_directory)

    return l:temporary_directory
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

function! s:GatherOutput(job_id, line) abort
    if has_key(s:job_info_map, a:job_id)
        call add(s:job_info_map[a:job_id].output, a:line)
    endif
endfunction

function! s:HandleLoclist(linter_name, buffer, loclist) abort
    " Make some adjustments to the loclists to fix common problems, and also
    " to set default values for loclist items.
    let l:linter_loclist = ale#engine#FixLocList(a:buffer, a:linter_name, a:loclist)

    " Remove previous items for this linter.
    call filter(g:ale_buffer_info[a:buffer].loclist, 'v:val.linter_name !=# a:linter_name')
    " Add the new items.
    call extend(g:ale_buffer_info[a:buffer].loclist, l:linter_loclist)

    " Sort the loclist again.
    " We need a sorted list so we can run a binary search against it
    " for efficient lookup of the messages in the cursor handler.
    call sort(g:ale_buffer_info[a:buffer].loclist, 'ale#util#LocItemCompare')

    let l:linting_is_done = empty(g:ale_buffer_info[a:buffer].job_list)
    \   && !get(g:ale_buffer_info[a:buffer], 'waiting_for_tsserver', 0)

    if l:linting_is_done
        " Automatically remove all managed temporary files and directories
        " now that all jobs have completed.
        call ale#engine#RemoveManagedFiles(a:buffer)

        " Figure out which linters are still enabled, and remove
        " problems for linters which are no longer enabled.
        let l:name_map = {}

        for l:linter in ale#linter#Get(getbufvar(a:buffer, '&filetype'))
            let l:name_map[l:linter.name] = 1
        endfor

        call filter(
        \   g:ale_buffer_info[a:buffer].loclist,
        \   'get(l:name_map, v:val.linter_name)',
        \)
    endif

    call ale#engine#SetResults(a:buffer, g:ale_buffer_info[a:buffer].loclist)

    if l:linting_is_done
        " Call user autocommands. This allows users to hook into ALE's lint cycle.
        silent doautocmd User ALELint
    endif
endfunction

function! s:HandleExit(job_id, exit_code) abort
    if !has_key(s:job_info_map, a:job_id)
        return
    endif

    let l:job_info = s:job_info_map[a:job_id]
    let l:linter = l:job_info.linter
    let l:output = l:job_info.output
    let l:buffer = l:job_info.buffer
    let l:next_chain_index = l:job_info.next_chain_index

    if g:ale_history_enabled
        call ale#history#SetExitCode(l:buffer, a:job_id, a:exit_code)
    endif

    " Remove this job from the list.
    call ale#job#Stop(a:job_id)
    call remove(s:job_info_map, a:job_id)
    call filter(g:ale_buffer_info[l:buffer].job_list, 'v:val !=# a:job_id')

    " Stop here if we land in the handle for a job completing if we're in
    " a sandbox.
    if ale#util#InSandbox()
        return
    endif

    if has('nvim') && !empty(l:output) && empty(l:output[-1])
        call remove(l:output, -1)
    endif

    if l:next_chain_index < len(get(l:linter, 'command_chain', []))
        call s:InvokeChain(l:buffer, l:linter, l:next_chain_index, l:output)
        return
    endif

    " Log the output of the command for ALEInfo if we should.
    if g:ale_history_enabled && g:ale_history_log_output
        call ale#history#RememberOutput(l:buffer, a:job_id, l:output[:])
    endif

    let l:loclist = ale#util#GetFunction(l:linter.callback)(l:buffer, l:output)

    call s:HandleLoclist(l:linter.name, l:buffer, l:loclist)
endfunction

function! s:HandleLSPResponse(response) abort
    let l:is_diag_response = get(a:response, 'type', '') ==# 'event'
    \   && get(a:response, 'event', '') ==# 'semanticDiag'

    if !l:is_diag_response
        return
    endif

    let l:buffer = bufnr(a:response.body.file)

    let l:info = get(g:ale_buffer_info, l:buffer, {})

    if empty(l:info)
        return
    endif

    let l:info.waiting_for_tsserver = 0

    let l:loclist = ale#lsp#response#ReadTSServerDiagnostics(a:response)

    call s:HandleLoclist('tsserver', l:buffer, l:loclist)
endfunction

function! ale#engine#SetResults(buffer, loclist) abort
    let l:info = get(g:ale_buffer_info, a:buffer, {})
    let l:job_list = get(l:info, 'job_list', [])
    let l:waiting_for_tsserver = get(l:info, 'waiting_for_tsserver', 0)
    let l:linting_is_done = empty(l:job_list) && !l:waiting_for_tsserver

    " Set signs first. This could potentially fix some line numbers.
    " The List could be sorted again here by SetSigns.
    if g:ale_set_signs
        call ale#sign#SetSigns(a:buffer, a:loclist)

        if l:linting_is_done
            call ale#sign#RemoveDummySignIfNeeded(a:buffer)
        endif
    endif

    if g:ale_set_quickfix || g:ale_set_loclist
        call ale#list#SetLists(a:buffer, a:loclist)

        if l:linting_is_done
            call ale#list#CloseWindowIfNeeded(a:buffer)
        endif
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

function! s:RemapItemTypes(type_map, loclist) abort
    for l:item in a:loclist
        let l:key = l:item.type
        \   . (get(l:item, 'sub_type', '') ==# 'style' ? 'S' : '')
        let l:new_key = get(a:type_map, l:key, '')

        if l:new_key ==# 'E'
        \|| l:new_key ==# 'ES'
        \|| l:new_key ==# 'W'
        \|| l:new_key ==# 'WS'
        \|| l:new_key ==# 'I'
            let l:item.type = l:new_key[0]

            if l:new_key ==# 'ES' || l:new_key ==# 'WS'
                let l:item.sub_type = 'style'
            elseif has_key(l:item, 'sub_type')
                call remove(l:item, 'sub_type')
            endif
        endif
    endfor
endfunction

function! ale#engine#FixLocList(buffer, linter_name, loclist) abort
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
        \   'linter_name': a:linter_name,
        \}

        if has_key(l:old_item, 'detail')
            let l:item.detail = l:old_item.detail
        endif

        " Pass on a end_col key if set, used for highlights.
        if has_key(l:old_item, 'end_col')
            let l:item.end_col = str2nr(l:old_item.end_col)
        endif

        if has_key(l:old_item, 'end_lnum')
            let l:item.end_lnum = str2nr(l:old_item.end_lnum)
        endif

        if has_key(l:old_item, 'sub_type')
            let l:item.sub_type = l:old_item.sub_type
        endif

        if l:item.lnum < 1
            " When errors appear before line 1, put them at line 1.
            let l:item.lnum = 1
        elseif l:item.lnum > l:last_line_number
            " When errors go beyond the end of the file, put them at the end.
            let l:item.lnum = l:last_line_number
        endif

        call add(l:new_loclist, l:item)
    endfor

    let l:type_map = get(ale#Var(a:buffer, 'type_map'), a:linter_name, {})

    if !empty(l:type_map)
        call s:RemapItemTypes(l:type_map, l:new_loclist)
    endif

    return l:new_loclist
endfunction

" Given part of a command, replace any % with %%, so that no characters in
" the string will be replaced with filenames, etc.
function! ale#engine#EscapeCommandPart(command_part) abort
    return substitute(a:command_part, '%', '%%', 'g')
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

    let [l:temporary_file, l:command] = ale#command#FormatCommand(l:buffer, l:command, l:read_buffer)

    if s:CreateTemporaryFileForJob(l:buffer, l:temporary_file)
        " If a temporary filename has been formatted in to the command, then
        " we do not need to send the Vim buffer to the command.
        let l:read_buffer = 0
    endif

    let l:command = ale#job#PrepareCommand(l:command)
    let l:job_options = {
    \   'mode': 'nl',
    \   'exit_cb': function('s:HandleExit'),
    \}

    if l:output_stream ==# 'stderr'
        let l:job_options.err_cb = function('s:GatherOutput')
    elseif l:output_stream ==# 'both'
        let l:job_options.out_cb = function('s:GatherOutput')
        let l:job_options.err_cb = function('s:GatherOutput')
    else
        let l:job_options.out_cb = function('s:GatherOutput')
    endif

    if get(g:, 'ale_run_synchronously') == 1
        " Find a unique Job value to use, which will be the same as the ID for
        " running commands synchronously. This is only for test code.
        let l:job_id = len(s:job_info_map) + 1

        while has_key(s:job_info_map, l:job_id)
            let l:job_id += 1
        endwhile
    else
        let l:job_id = ale#job#Start(l:command, l:job_options)
    endif

    let l:status = 'failed'

    " Only proceed if the job is being run.
    if l:job_id
        " Add the job to the list of jobs, so we can track them.
        call add(g:ale_buffer_info[l:buffer].job_list, l:job_id)

        let l:status = 'started'
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

    if get(g:, 'ale_run_synchronously') == 1
        " Run a command synchronously if this test option is set.
        let s:job_info_map[l:job_id].output = systemlist(
        \   type(l:command) == type([])
        \   ?  join(l:command[0:1]) . ' ' . ale#Escape(l:command[2])
        \   : l:command
        \)

        call l:job_options.exit_cb(l:job_id, v:shell_error)
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
    else
        let l:command = ale#linter#GetCommand(a:buffer, a:linter)
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

function! ale#engine#StopCurrentJobs(buffer, include_lint_file_jobs) abort
    let l:info = get(g:ale_buffer_info, a:buffer, {})
    let l:new_job_list = []

    for l:job_id in get(l:info, 'job_list', [])
        let l:job_info = get(s:job_info_map, l:job_id, {})

        if !empty(l:job_info)
            if a:include_lint_file_jobs || !l:job_info.linter.lint_file
                call ale#job#Stop(l:job_id)
                call remove(s:job_info_map, l:job_id)
            else
                call add(l:new_job_list, l:job_id)
            endif
        endif
    endfor

    " Update the List, so it includes only the jobs we still need.
    let l:info.job_list = l:new_job_list
    " Ignore current LSP commands.
    " We should consider cancelling them in future.
    let l:info.lsp_command_list = []
endfunction

function! s:CheckWithTSServer(buffer, linter, executable) abort
    let l:info = g:ale_buffer_info[a:buffer]

    let l:command = ale#job#PrepareCommand(
    \ ale#linter#GetCommand(a:buffer, a:linter),
    \)
    let l:id = ale#lsp#StartProgram(
    \   a:executable,
    \   l:command,
    \   function('s:HandleLSPResponse'),
    \)

    if !l:id
        if g:ale_history_enabled
            call ale#history#Add(a:buffer, 'failed', l:id, l:command)
        endif

        return
    endif

    if ale#lsp#OpenTSServerDocumentIfNeeded(l:id, a:buffer)
        if g:ale_history_enabled
            call ale#history#Add(a:buffer, 'started', l:id, l:command)
        endif
    endif

    call ale#lsp#Send(l:id, ale#lsp#tsserver_message#Change(a:buffer))

    let l:request_id = ale#lsp#Send(
    \   l:id,
    \   ale#lsp#tsserver_message#Geterr(a:buffer),
    \)

    if l:request_id != 0
        let l:info.waiting_for_tsserver = 1
    endif
endfunction

function! ale#engine#Invoke(buffer, linter) abort
    if empty(a:linter.lsp) || a:linter.lsp ==# 'tsserver'
        let l:executable = ale#linter#GetExecutable(a:buffer, a:linter)

        " Run this program if it can be executed.
        if s:IsExecutable(l:executable)
            if a:linter.lsp ==# 'tsserver'
                call s:CheckWithTSServer(a:buffer, a:linter, l:executable)
            else
                call s:InvokeChain(a:buffer, a:linter, 0, [])
            endif
        endif
    endif
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
    let l:start_time = ale#util#ClockMilliseconds()

    if l:start_time == 0
        throw 'Failed to read milliseconds from the clock!'
    endif

    let l:job_list = []

    " Gather all of the jobs from every buffer.
    for l:info in values(g:ale_buffer_info)
        call extend(l:job_list, l:info.job_list)
    endfor

    " NeoVim has a built-in API for this, so use that.
    if has('nvim')
        let l:nvim_code_list = jobwait(l:job_list, a:deadline)

        if index(l:nvim_code_list, -1) >= 0
            throw 'Jobs did not complete on time!'
        endif

        return
    endif

    let l:should_wait_more = 1

    while l:should_wait_more
        let l:should_wait_more = 0

        for l:job_id in l:job_list
            if ale#job#IsRunning(l:job_id)
                let l:now = ale#util#ClockMilliseconds()

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

    " Check again to see if any jobs are running.
    for l:info in values(g:ale_buffer_info)
        for l:job_id in l:info.job_list
            if ale#job#IsRunning(l:job_id)
                let l:has_new_jobs = 1
                break
            endif
        endfor
    endfor

    if l:has_new_jobs
        " We have to wait more. Offset the timeout by the time taken so far.
        let l:now = ale#util#ClockMilliseconds()
        let l:new_deadline = a:deadline - (l:now - l:start_time)

        if l:new_deadline <= 0
            " Enough time passed already, so stop immediately.
            throw 'Jobs did not complete on time!'
        endif

        call ale#engine#WaitForJobs(l:new_deadline)
    endif
endfunction
