" These versions of Vim have bugs with the 'in_buf' option, so the buffer
" must be sent via getbufline() instead.
let s:has_in_buf_bugs = has('win32') || has('gui_macvim')

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

function! s:ClearJob(job) abort
    let job_id = s:GetJobID(a:job)
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

function! s:GatherOutput(job, data) abort
    let job_id = s:GetJobID(a:job)

    if !has_key(s:job_info_map, job_id)
        return
    endif

    call extend(s:job_info_map[job_id].output, a:data)
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

    let job_id = s:GetJobID(a:job)

    if !has_key(s:job_info_map, job_id)
        return
    endif

    let job_info = s:job_info_map[job_id]

    call s:ClearJob(a:job)

    let linter = job_info.linter
    let output = job_info.output
    let buffer = job_info.buffer

    let linter_loclist = ale#util#GetFunction(linter.callback)(buffer, output)

    " Make some adjustments to the loclists to fix common problems.
    call s:FixLocList(buffer, linter_loclist)

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
    let last_line_number = ale#util#GetLineCount(a:buffer)

    for item in a:loclist
        if item.lnum == 0
            " When errors appear at line 0, put them at line 1 instead.
            let item.lnum = 1
        elseif item.lnum > last_line_number
            let item.lnum = last_line_number
        endif
    endfor
endfunction

function! ale#engine#invoke(buffer, linter) abort
    if has_key(a:linter, 'job')
        " Stop previous jobs for the same linter.
        call s:ClearJob(a:linter.job)
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
            \   'on_stderr': 's:GatherOutputNeoVim',
            \   'on_exit': 's:HandleExitNeoVim',
            \})
        elseif a:linter.output_stream ==# 'both'
            let job = jobstart(command, {
            \   'on_stdout': 's:GatherOutputNeoVim',
            \   'on_stderr': 's:GatherOutputNeoVim',
            \   'on_exit': 's:HandleExitNeoVim',
            \})
        else
            let job = jobstart(command, {
            \   'on_stdout': 's:GatherOutputNeoVim',
            \   'on_exit': 's:HandleExitNeoVim',
            \})
        endif
    else
        let job_options = {
        \   'in_mode': 'nl',
        \   'out_mode': 'nl',
        \   'err_mode': 'nl',
        \   'close_cb': function('s:HandleExitVim'),
        \}

        if a:linter.output_stream ==# 'stderr'
            " Read from stderr instead of stdout.
            let job_options.err_cb = function('s:GatherOutputVim')
        elseif a:linter.output_stream ==# 'both'
            " Read from both streams.
            let job_options.out_cb = function('s:GatherOutputVim')
            let job_options.err_cb = function('s:GatherOutputVim')
        else
            let job_options.out_cb = function('s:GatherOutputVim')
        endif

        if has('win32')
            " job_start commands on Windows have to be run with cmd /c,
            " othwerwise %PATHTEXT% will not be used to programs ending int
            " .cmd, .bat, .exe, etc.
            let l:command = 'cmd /c ' . l:command
        endif

        if !s:has_in_buf_bugs
            " On some Unix machines, we can send the Vim buffer directly.
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
        let s:job_info_map[s:GetJobID(job)] = {
        \   'linter': a:linter,
        \   'buffer': a:buffer,
        \   'output': [],
        \}

        if has('nvim')
            " In NeoVim, we have to send the buffer lines ourselves.
            let input = join(getbufline(a:buffer, 1, '$'), "\n") . "\n"

            call jobsend(job, input)
            call jobclose(job, 'stdin')
        elseif s:has_in_buf_bugs
            " On some Vim versions, we have to send the buffer data ourselves.
            let input = join(getbufline(a:buffer, 1, '$'), "\n") . "\n"
            let channel = job_getchannel(job)

            if ch_status(channel) ==# 'open'
                call ch_sendraw(channel, input)
                call ch_close_in(channel)
            endif
        endif
    endif
endfunction
