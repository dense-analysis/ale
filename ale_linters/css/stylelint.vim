" Author: diartyz <diartyz@gmail.com>

let g:ale_css_stylelint_executable =
\   get(g:, 'ale_css_stylelint_executable', 'stylelint')

let g:ale_css_stylelint_options =
\   get(g:, 'ale_css_stylelint_options', '')

let g:ale_css_stylelint_use_global =
\   get(g:, 'ale_css_stylelint_use_global', 0)

function! ale_linters#css#stylelint#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'css_stylelint_use_global')
        return ale#Var(a:buffer, 'css_stylelint_executable')
    endif

    return ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/stylelint',
    \   ale#Var(a:buffer, 'css_stylelint_executable')
    \)
endfunction

function! ale_linters#css#stylelint#GetCommand(buffer) abort
    return ale_linters#css#stylelint#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'css_stylelint_options')
    \   . ' --stdin-filename %s'
endfunction

call ale#linter#Define('css', {
\   'name': 'stylelint',
\   'executable_callback': 'ale_linters#css#stylelint#GetExecutable',
\   'command_callback': 'ale_linters#css#stylelint#GetCommand',
\   'callback': 'ale#handlers#css#HandleStyleLintFormat',
\})
