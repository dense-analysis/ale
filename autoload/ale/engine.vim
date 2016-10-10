" Stores information for each job including:
"
" linter: The linter dictionary for the job.
" buffer: The buffer number for the job.
" output: The array of lines for the output of the job.
let s:job_info_map = {}

function! ale#engine#GetJobID(job)
    if has('nvim')
        "In NeoVim, job values are just IDs.
        return a:job
    endif

    " In Vim 8, the job is a special variable, and we open a channel for each
    " job. We'll use the ID of the channel instead as the job ID.
    return ch_info(job_getchannel(a:job)).id
endfunction

function! ale#engine#ClearJob(job)
    let job_id = ale#engine#GetJobID(a:job)
    let linter = s:job_info_map[job_id].linter

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

    call remove(s:job_info_map, job_id)
    call remove(linter, 'job')
endfunction

function! s:GatherOutput(job, data)
    let job_id = ale#engine#GetJobID(a:job)

    if !has_key(s:job_info_map, job_id)
        return
    endif

    call extend(s:job_info_map[job_id].output, a:data)
endfunction

function! ale#engine#GatherOutputVim(channel, data)
    call s:GatherOutput(ch_getjob(a:channel), [a:data])
endfunction

function! ale#engine#GatherOutputNeoVim(job, data, event)
    call s:GatherOutput(a:job, a:data)
endfunction

function! s:HandleExit(job)
    if a:job ==# 'no process'
        " Stop right away when the job is not valid in Vim 8.
        return
    endif

    let job_id = ale#engine#GetJobID(a:job)

    if !has_key(s:job_info_map, job_id)
        return
    endif

    let job_info = s:job_info_map[job_id]

    call ale#engine#ClearJob(a:job)

    let linter = job_info.linter
    let output = job_info.output
    let buffer = job_info.buffer

    let linter_loclist = ale#util#GetFunction(linter.callback)(buffer, output)

    " Make some adjustments to the loclists to fix common problems.
    call ale#util#FixLocList(buffer, linter_loclist)

    if g:ale_buffer_should_reset_map[buffer]
        let g:ale_buffer_should_reset_map[buffer] = 0
        let g:ale_buffer_loclist_map[buffer] = []
    endif

    " Add the loclist items from the linter.
    call extend(g:ale_buffer_loclist_map[buffer], linter_loclist)

    " Sort the loclist again.
    " We need a sorted list so we can run a binary search against it
    " for efficient lookup of the messages in the cursor handler.
    call sort(g:ale_buffer_loclist_map[buffer], 'ale#util#LocItemCompare')

    if g:ale_set_loclist
        call setloclist(0, g:ale_buffer_loclist_map[buffer])
    endif

    if g:ale_set_signs
        call ale#sign#SetSigns(buffer, g:ale_buffer_loclist_map[buffer])
    endif

    " Mark line 200, column 17 with a squiggly line or something
    " matchadd('ALEError', '\%200l\%17v')
endfunction

function! ale#engine#HandleExitNeoVim(job, data, event)
    call s:HandleExit(a:job)
endfunction

function! ale#engine#HandleExitVim(channel)
    call s:HandleExit(ch_getjob(a:channel))
endfunction

function! ale#engine#ApplyLinter(buffer, linter)
    if has_key(a:linter, 'job')
        " Stop previous jobs for the same linter.
        call ale#engine#ClearJob(a:linter.job)
    endif

    if has_key(a:linter, 'command_callback')
        " If there is a callback for generating a command, call that instead.
        let command = ale#util#GetFunction(a:linter.command_callback)(a:buffer)
    else
        let command = a:linter.command
    endif

    if command =~# '%s'
        " If there is a '%s' in the command string, replace it with the name
        " of the file.
        let command = printf(command, shellescape(fnamemodify(bufname(a:buffer), ':p')))
    endif

    if has('nvim')
        if a:linter.output_stream ==# 'stderr'
            " Read from stderr instead of stdout.
            let job = jobstart(command, {
            \   'on_stderr': 'ale#engine#GatherOutputNeoVim',
            \   'on_exit': 'ale#engine#HandleExitNeoVim',
            \})
        elseif a:linter.output_stream ==# 'both'
            let job = jobstart(command, {
            \   'on_stdout': 'ale#engine#GatherOutputNeoVim',
            \   'on_stderr': 'ale#engine#GatherOutputNeoVim',
            \   'on_exit': 'ale#engine#HandleExitNeoVim',
            \})
        else
            let job = jobstart(command, {
            \   'on_stdout': 'ale#engine#GatherOutputNeoVim',
            \   'on_exit': 'ale#engine#HandleExitNeoVim',
            \})
        endif
    else
        let job_options = {
        \   'in_mode': 'nl',
        \   'out_mode': 'nl',
        \   'err_mode': 'nl',
        \   'close_cb': function('ale#engine#HandleExitVim'),
        \}

        if a:linter.output_stream ==# 'stderr'
            " Read from stderr instead of stdout.
            let job_options.err_cb = function('ale#engine#GatherOutputVim')
        elseif a:linter.output_stream ==# 'both'
            " Read from both streams.
            let job_options.out_cb = function('ale#engine#GatherOutputVim')
            let job_options.err_cb = function('ale#engine#GatherOutputVim')
        else
            let job_options.out_cb = function('ale#engine#GatherOutputVim')
        endif

        if has('win32')
            " job_start commands on Windows have to be run with cmd /c,
            " othwerwise %PATHTEXT% will not be used to programs ending int
            " .cmd, .bat, .exe, etc.
            let l:command = 'cmd /c ' . l:command
        else
            " On Unix machines, we can send the Vim buffer directly.
            " This is faster than reading the lines ourselves.
            let job_options.in_io = 'buffer'
            let job_options.in_buf = a:buffer
        endif

        " Vim 8 will read the stdin from the file's buffer.
        let job = job_start(l:command, l:job_options)
    endif

    " Only proceed if the job is being run.
    if has('nvim') || (job !=# 'no process' && job_status(job) ==# 'run')
        let a:linter.job = job

        " Store the ID for the job in the map to read back again.
        let s:job_info_map[ale#engine#GetJobID(job)] = {
        \   'linter': a:linter,
        \   'buffer': a:buffer,
        \   'output': [],
        \}

        if has('nvim')
            " In NeoVim, we have to send the buffer lines ourselves.
            let input = join(getbufline(a:buffer, 1, '$'), "\n") . "\n"

            call jobsend(job, input)
            call jobclose(job, 'stdin')
        elseif has('win32')
            " On Windows, we have to send the buffer lines ourselves,
            " as there are issues with Windows and 'in_buf'
            let input = join(getbufline(a:buffer, 1, '$'), "\n") . "\n"
            let channel = job_getchannel(job)

            if ch_status(channel) ==# 'open'
                call ch_sendraw(channel, input)
                call ch_close_in(channel)
            endif
        endif
    endif
endfunction

