" Author: diartyz <diartyz@gmail.com>

let g:ale_sass_stylelint_executable =
\   get(g:, 'ale_sass_stylelint_executable', 'stylelint')

let g:ale_sass_stylelint_use_global =
\   get(g:, 'ale_sass_stylelint_use_global', 0)

function! ale_linters#sass#stylelint#GetExecutable(buffer) abort
    if g:ale_sass_stylelint_use_global
        return g:ale_sass_stylelint_executable
    endif

    return ale#util#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/stylelint',
    \   g:ale_sass_stylelint_executable
    \)
endfunction

function! ale_linters#sass#stylelint#GetCommand(buffer) abort
    return ale_linters#sass#stylelint#GetExecutable(a:buffer)
    \   . ' --stdin-filename %s'
endfunction

call ale#linter#Define('sass', {
\   'name': 'stylelint',
\   'executable_callback': 'ale_linters#sass#stylelint#GetExecutable',
\   'command_callback': 'ale_linters#sass#stylelint#GetCommand',
\   'callback': 'ale#handlers#HandleStyleLintFormat',
\})
