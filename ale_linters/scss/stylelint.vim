" Author: diartyz <diartyz@gmail.com>

let g:ale_scss_stylelint_executable =
\   get(g:, 'ale_scss_stylelint_executable', 'stylelint')

let g:ale_scss_stylelint_use_global =
\   get(g:, 'ale_scss_stylelint_use_global', 0)

function! ale_linters#scss#stylelint#GetExecutable(buffer) abort
    if g:ale_scss_stylelint_use_global
        return g:ale_scss_stylelint_executable
    endif

    return ale#util#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/stylelint',
    \   g:ale_scss_stylelint_executable
    \)
endfunction

function! ale_linters#scss#stylelint#GetCommand(buffer) abort
    return ale_linters#scss#stylelint#GetExecutable(a:buffer)
    \   . ' --stdin-filename %s'
endfunction

call ale#linter#Define('scss', {
\   'name': 'stylelint',
\   'executable_callback': 'ale_linters#scss#stylelint#GetExecutable',
\   'command_callback': 'ale_linters#scss#stylelint#GetCommand',
\   'callback': 'ale#handlers#HandleStyleLintFormat',
\})
