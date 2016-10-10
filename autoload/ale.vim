" Author: w0rp <devw0rp@gmail.com>
" Description: Primary code path for the plugin
"   Manages execution of linters when requested by autocommands

let s:lint_timer = -1

function! ale#queue(delay)
    if s:lint_timer != -1
        call timer_stop(s:lint_timer)
        let s:lint_timer = -1
    endif

    let linters = ale#linter#get(&filetype)
    if len(linters) == 0
        " There are no linters to lint with, so stop here.
        return
    endif

    if a:delay > 0
        let s:lint_timer = timer_start(a:delay, function('ale#lint'))
    else
        call ale#lint()
    endif
endfunction

function! ale#lint(...)
    let buffer = bufnr('%')
    let linters = ale#linter#get(&filetype)

    " Set a variable telling us to clear the loclist later.
    let g:ale_buffer_should_reset_map[buffer] = 1

    for linter in linters
        " Check if a given linter has a program which can be executed.
        if has_key(linter, 'executable_callback')
            let l:executable = ale#util#GetFunction(linter.executable_callback)(buffer)
        else
            let l:executable = linter.executable
        endif

        if !executable(l:executable)
            " The linter's program cannot be executed, so skip it.
            continue
        endif

        call ale#engine#ApplyLinter(buffer, linter)
    endfor
endfunction

