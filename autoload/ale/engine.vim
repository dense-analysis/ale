" Author: w0rp <devw0rp@gmail.com>
" Description: Backend execution and job management
"   Executes linters in the background, using NeoVim or Vim 8 jobs

" Stores information for each job including:
"
" linter: The linter dictionary for the job.
" buffer: The buffer number for the job.
" output: The array of lines for the output of the job.
let s:job_info_map = {}

function! s:GetJobID(job) abort
    if has('nvim')
        "In NeoVim, job values are just IDs.
        return a:job
    endif

    " In Vim 8, the job is a special variable, and we open a channel for each
    " job. We'll use the ID of the channel instead as the job ID.
    return ch_info(job_getchannel(a:job)).id
endfunction

function! ale#engine#InitBufferInfo(buffer) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        " job_list will hold the list of jobs
        " loclist holds the loclist items after all jobs have completed.
        " new_loclist holds loclist items while jobs are being run.
        let g:ale_buffer_info[a:buffer] = {
        \   'job_list': [],
        \   'loclist': [],
        \   'new_loclist': [],
        \}
    endif
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

        call job_stop(a:job)
    endif

    call remove(s:job_info_map, l:job_id)
endfunction

function! s:StopPreviousJobs(buffer, linter) abort
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

function! s:GatherOutput(job, data) abort
    let l:job_id = s:GetJobID(a:job)

    if !has_key(s:job_info_map, l:job_id)
        return
    endif

    call extend(s:job_info_map[l:job_id].output, a:data)
endfunction

function! s:GatherOutputVim(channel, data) abort
    call s:GatherOutput(ch_getjob(a:channel), [a:data])
endfunction

function! s:GatherOutputNeoVim(job, data, event) abort
    call s:GatherOutput(a:job, a:data)
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

    if l:next_chain_index < len(get(l:linter, 'command_chain', []))
        call s:InvokeChain(l:buffer, l:linter, l:next_chain_index, l:output)
        return
    endif

    let l:linter_loclist = ale#util#GetFunction(l:linter.callback)(l:buffer, l:output)

    " Make some adjustments to the loclists to fix common problems.
    call s:FixLocList(l:buffer, l:linter_loclist)

    for l:item in l:linter_loclist
        let l:item.linter_name = l:linter.name
    endfor

    " Add the loclist items from the linter.
    call extend(g:ale_buffer_info[l:buffer].new_loclist, l:linter_loclist)

    if !empty(g:ale_buffer_info[l:buffer].job_list)
        " Wait for all jobs to complete before doing anything else.
        return
    endif

    " Sort the loclist again.
    " We need a sorted list so we can run a binary search against it
    " for efficient lookup of the messages in the cursor handler.
    call sort(g:ale_buffer_info[l:buffer].new_loclist, 'ale#util#LocItemCompare')

    " Now swap the old and new loclists, after we have collected everything
    " and sorted the list again.
    let g:ale_buffer_info[l:buffer].loclist = g:ale_buffer_info[l:buffer].new_loclist
    let g:ale_buffer_info[l:buffer].new_loclist = []

    if g:ale_set_loclist
        call setloclist(0, g:ale_buffer_info[l:buffer].loclist)
    endif

    if g:ale_set_signs
        call ale#sign#SetSigns(l:buffer, g:ale_buffer_info[l:buffer].loclist)
    endif

    if exists('*ale#statusline#Update')
        " Don't load/run if not already loaded.
        call ale#statusline#Update(l:buffer, g:ale_buffer_info[l:buffer].loclist)
    endif

    " Call user autocommands. This allows users to hook into ALE's lint cycle.
    silent doautocmd User ALELint

    " Mark line 200, column 17 with a squiggly line or something
    " matchadd('ALEError', '\%200l\%17v')
endfunction

function! s:HandleExitNeoVim(job, data, event) abort
    call s:HandleExit(a:job)
endfunction

function! s:HandleExitVim(channel) abort
    call s:HandleExit(ch_getjob(a:channel))
endfunction

function! s:FixLocList(buffer, loclist) abort
    " Some errors have line numbers beyond the end of the file,
    " so we need to adjust them so they set the error at the last line
    " of the file instead.
    let l:last_line_number = ale#util#GetLineCount(a:buffer)

    for l:item in a:loclist
        if l:item.lnum == 0
            " When errors appear at line 0, put them at line 1 instead.
            let l:item.lnum = 1
        elseif l:item.lnum > l:last_line_number
            let l:item.lnum = l:last_line_number
        endif
    endfor
endfunction

function! s:RunJob(command, generic_job_options) abort
    let l:buffer = a:generic_job_options.buffer
    let l:linter = a:generic_job_options.linter
    let l:output_stream = a:generic_job_options.output_stream
    let l:next_chain_index = a:generic_job_options.next_chain_index
    let l:command = a:command

    if l:command =~# '%s'
        " If there is a '%s' in the command string, replace it with the name
        " of the file.
        let l:command = printf(l:command, shellescape(fnamemodify(bufname(l:buffer), ':p')))
    endif

    if has('nvim')
        if l:output_stream ==# 'stderr'
            " Read from stderr instead of stdout.
            let l:job = jobstart(l:command, {
            \   'on_stderr': 's:GatherOutputNeoVim',
            \   'on_exit': 's:HandleExitNeoVim',
            \})
        elseif l:output_stream ==# 'both'
            let l:job = jobstart(l:command, {
            \   'on_stdout': 's:GatherOutputNeoVim',
            \   'on_stderr': 's:GatherOutputNeoVim',
            \   'on_exit': 's:HandleExitNeoVim',
            \})
        else
            let l:job = jobstart(l:command, {
            \   'on_stdout': 's:GatherOutputNeoVim',
            \   'on_exit': 's:HandleExitNeoVim',
            \})
        endif
    else
        let l:job_options = {
        \   'in_mode': 'nl',
        \   'out_mode': 'nl',
        \   'err_mode': 'nl',
        \   'close_cb': function('s:HandleExitVim'),
        \}

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

        if has('win32')
            " job_start commands on Windows have to be run with cmd /c,
            " othwerwise %PATHTEXT% will not be used to programs ending int
            " .cmd, .bat, .exe, etc.
            let l:command = 'cmd /c ' . l:command
        else
            " Execute the command with the shell, to fix escaping issues.
            let l:command = split(&shell) + split(&shellcmdflag) + [l:command]

            " On Unix machines, we can send the Vim buffer directly.
            " This is faster than reading the lines ourselves.
            let l:job_options.in_io = 'buffer'
            let l:job_options.in_buf = l:buffer
        endif

        " Vim 8 will read the stdin from the file's buffer.
        let l:job = job_start(l:command, l:job_options)
    endif

    " Only proceed if the job is being run.
    if has('nvim') || (l:job !=# 'no process' && job_status(l:job) ==# 'run')
        " Add the job to the list of jobs, so we can track them.
        call add(g:ale_buffer_info[l:buffer].job_list, l:job)

        " Store the ID for the job in the map to read back again.
        let s:job_info_map[s:GetJobID(l:job)] = {
        \   'linter': l:linter,
        \   'buffer': l:buffer,
        \   'output': [],
        \   'next_chain_index': l:next_chain_index,
        \}

        if has('nvim')
            " In NeoVim, we have to send the buffer lines ourselves.
            let l:input = join(getbufline(l:buffer, 1, '$'), "\n") . "\n"

            call jobsend(l:job, l:input)
            call jobclose(l:job, 'stdin')
        elseif has('win32')
            " On some Vim versions, we have to send the buffer data ourselves.
            let l:input = join(getbufline(l:buffer, 1, '$'), "\n") . "\n"
            let l:channel = job_getchannel(l:job)

            if ch_status(l:channel) ==# 'open'
                call ch_sendraw(l:channel, l:input)
                call ch_close_in(l:channel)
            endif
        endif
    endif
endfunction

function! s:InvokeChain(buffer, linter, chain_index, input) abort
    let l:output_stream = get(a:linter, 'output_stream', 'stdout')

    if has_key(a:linter, 'command_chain')
        " Run a chain of commands, one asychronous command after the other,
        " so that many programs can be run in a sequence.
        let l:chain_item = a:linter.command_chain[a:chain_index]

        " The chain item can override the output_stream option.
        if has_key(l:chain_item)
            let l:output_stream = l:chain_item.output_stream
        endif

        let l:callback = ale#util#GetFunction(a:linter.callback)

        if a:chain_index == 0
            " The first callback in the chain takes only a buffer number.
            let l:command = l:callback(a:buffer)
        else
            " The second callback in the chain takes some input too.
            let l:command = l:callback(a:buffer, a:input)
        endif
    elseif has_key(a:linter, 'command_callback')
        " If there is a callback for generating a command, call that instead.
        let l:command = ale#util#GetFunction(a:linter.command_callback)(a:buffer)
    else
        let l:command = a:linter.command
    endif

    call s:RunJob(l:command, {
    \   'buffer': a:buffer,
    \   'linter': a:linter,
    \   'output_stream': l:output_stream,
    \   'next_chain_index': a:chain_index + 1,
    \})
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
endfunction
