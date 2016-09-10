" Always set buffer variables for each buffer
let b:ale_should_reset_loclist = 0
let b:ale_loclist = []

if exists('g:loaded_ale_zmain')
    finish
endif

let g:loaded_ale_zmain = 1

let s:lint_timer = -1
let s:linters = {}
let s:job_linter_map = {}
let s:job_output_map = {}

function! s:ClearJob(job)
    let linter = s:job_linter_map[a:job]

    if has('nvim')
        call jobstop(a:job)
    else
        call job_stop(a:job)
    endif

    call remove(s:job_output_map, a:job)
    call remove(s:job_linter_map, a:job)
    call remove(linter, 'job')
endfunction

function! s:GatherOutput(job, data)
    if !has_key(s:job_output_map, a:job)
        return
    endif

    call extend(s:job_output_map[a:job], a:data)
endfunction

function! s:GatherOutputNeoVim(job, data, event)
    call s:GatherOutput(a:job, a:data)
endfunction

function! s:GatherOutputVim(channel, data)
    call s:GatherOutput(ch_getjob(a:channel), [a:data])
endfunction

function! s:LocItemCompare(left, right)
    if a:left['lnum'] < a:right['lnum']
        return -1
    endif

    if a:left['lnum'] > a:right['lnum']
        return 1
    endif

    if a:left['col'] < a:right['col']
        return -1
    endif

    if a:left['col'] > a:right['col']
        return 1
    endif

    return 0
endfunction

function! s:HandleExit(job)
    if !has_key(s:job_linter_map, a:job)
        return
    endif

    let linter = s:job_linter_map[a:job]
    let output = s:job_output_map[a:job]

    call s:ClearJob(a:job)

    let linter_loclist = function(linter.callback)(output)

    if b:ale_should_reset_loclist
        let b:ale_should_reset_loclist = 0
        let b:ale_loclist = []
    endif

    " Add the loclist items from the linter.
    call extend(b:ale_loclist, linter_loclist)

    " Sort the loclist again.
    " We need a sorted list so we can run a binary search against it
    " for efficient lookup of the messages in the cursor handler.
    call sort(b:ale_loclist, 's:LocItemCompare')

    if g:ale_set_loclist
        call setloclist(0, b:ale_loclist)
    endif

    if g:ale_set_signs
        call ale#sign#SetSigns(b:ale_loclist)
    endif

    " Mark line 200, column 17 with a squiggly line or something
    " matchadd('ALEError', '\%200l\%17v')
endfunction

function! s:HandleExitNeoVim(job, data, event)
    call s:HandleExit(a:job)
endfunction

function! s:HandleExitVim(channel)
    call s:HandleExit(ch_getjob(a:channel))
endfunction

function! s:ApplyLinter(linter)
    if has_key(a:linter, 'job')
        " Stop previous jobs for the same linter.
        call s:ClearJob(a:linter.job)
    endif

    if has('nvim')
        let a:linter.job = jobstart(a:linter.command, {
        \   'on_stdout': 's:GatherOutputNeoVim',
        \   'on_exit': 's:HandleExitNeoVim',
        \})
    else
        " Vim 8 will read the stdin from the file's buffer.
        let a:linter.job = job_start(a:linter.command, {
        \   'out_mode': 'nl',
        \   'err_mode': 'nl',
        \   'out_cb': function('s:GatherOutputVim'),
        \   'close_cb': function('s:HandleExitVim'),
        \   'in_io': 'buffer',
        \   'in_buf': bufnr('%'),
        \})

        call ch_close_in(job_getchannel(a:linter.job))
    endif

    let s:job_linter_map[a:linter.job] = a:linter
    let s:job_output_map[a:linter.job] = []

    if has('nvim')
        " For NeoVim, we have to send the text in the buffer to the command.
        call jobsend(a:linter.job, join(getline(1, '$'), "\n") . "\n")
        call jobclose(a:linter.job, 'stdin')
    endif
endfunction

function! s:TimerHandler(...)
    let filetype = &filetype
    let linters = ALEGetLinters(filetype)

    " Set a variable telling us to clear the loclist later.
    let b:ale_should_reset_loclist = 1

    for linter in linters
        call s:ApplyLinter(linter)
    endfor
endfunction

function! ALEAddLinter(filetype, linter)
    " Check if the linter program is executable before adding it.
    if !executable(a:linter.executable)
        return
    endif

    if !has_key(s:linters, a:filetype)
        let s:linters[a:filetype] = []
    endif

    call add(s:linters[a:filetype], {
    \   'command': a:linter.command,
    \   'callback': a:linter.callback,
    \})
endfunction

function! ALEGetLinters(filetype)
    if !has_key(s:linters, a:filetype)
        return []
    endif

    return s:linters[a:filetype]
endfunction

function! ALELint(delay)
    let filetype = &filetype
    let linters = ALEGetLinters(filetype)

    if s:lint_timer != -1
        call timer_stop(s:lint_timer)
        let s:lint_timer = -1
    endif

    if len(linters) == 0
        " There are no linters to lint with, so stop here.
        return
    endif

    if a:delay > 0
        let s:lint_timer = timer_start(a:delay, function('s:TimerHandler'))
    else
        call s:TimerHandler()
    endif
endfunction

" Load all of the linters for each filetype.
runtime ale_linters/*/*.vim

if !has('nvim') && !(has('timers') && has('job') && has('channel'))
    echoerr 'ALE requires NeoVim or Vim 8 with +timers +job +channel'
    echoerr 'ALE will not be run automatically'
    finish
endif

if g:ale_lint_on_text_changed
    augroup ALERunOnTextChangedGroup
        autocmd!
        autocmd TextChanged,TextChangedI * call ALELint(g:ale_lint_delay)
    augroup END
endif

if g:ale_lint_on_enter
    augroup ALERunOnEnterGroup
        autocmd!
        autocmd BufEnter * call ALELint(0)
    augroup END
endif
