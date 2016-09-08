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
    if a:job != -1
        let linter = s:job_linter_map[a:job]

        call jobstop(a:job)
        call remove(s:job_output_map, a:job)
        call remove(s:job_linter_map, a:job)

        let linter.job = -1
    endif
endfunction

function! s:GatherOutput(job, data, event)
    if !has_key(s:job_output_map, a:job)
        return
    endif

    call extend(s:job_output_map[a:job], a:data)
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

function! s:HandleExit(job, data, event)
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

function! s:ApplyLinter(linter)
    " Stop previous jobs for the same linter.
    call s:ClearJob(a:linter.job)

    let a:linter.job = jobstart(a:linter.command, {
    \   'on_stdout': 's:GatherOutput',
    \   'on_exit': 's:HandleExit',
    \})

    let s:job_linter_map[a:linter.job] = a:linter
    let s:job_output_map[a:linter.job] = []

    call jobsend(a:linter.job, join(getline(1, '$'), "\n") . "\n")
    call jobclose(a:linter.job, 'stdin')
endfunction

function! s:TimerHandler()
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
    \   'job': -1,
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
        let s:lint_timer = timer_start(a:delay, 's:TimerHandler')
    else
        call s:TimerHandler()
    endif
endfunction

" Load all of the linters for each filetype.
runtime ale_linters/*/*.vim

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
