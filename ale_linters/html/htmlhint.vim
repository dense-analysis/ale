" Author: KabbAmine <amine.kabb@gmail.com>, deathmaz <00maz1987@gmail.com>, diartyz <diartyz@gmail.com>
" Description: HTMLHint for checking html files

" CLI options
let g:ale_html_htmlhint_options = get(g:, 'ale_html_htmlhint_options', '--format=unix')

let g:ale_html_htmlhint_executable =
\   get(g:, 'ale_html_htmlhint_executable', 'htmlhint')

let g:ale_html_htmlhint_use_global =
\   get(g:, 'ale_html_htmlhint_use_global', 0)

function! ale_linters#html#htmlhint#GetExecutable(buffer) abort
    if g:ale_html_htmlhint_use_global
        return g:ale_html_htmlhint_executable
    endif

    return ale#util#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/htmlhint',
    \   g:ale_html_htmlhint_executable
    \)
endfunction

function! ale_linters#html#htmlhint#GetCommand(buffer) abort
    return ale_linters#html#htmlhint#GetExecutable(a:buffer)
    \   . ' ' . g:ale_html_htmlhint_options
    \   . ' %t'
endfunction

call ale#linter#Define('html', {
\   'name': 'htmlhint',
\   'executable_callback': 'ale_linters#html#htmlhint#GetExecutable',
\   'command_callback': 'ale_linters#html#htmlhint#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
