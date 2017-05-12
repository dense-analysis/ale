" Author: Daniel Lupu <lupu.daniel.f@gmail.com>
" Description: xo for JavaScript files

let g:ale_javascript_xo_executable =
\   get(g:, 'ale_javascript_xo_executable', 'xo')

let g:ale_javascript_xo_options =
\   get(g:, 'ale_javascript_xo_options', '')

let g:ale_javascript_xo_use_global =
\   get(g:, 'ale_javascript_xo_use_global', 0)

function! ale_linters#javascript#xo#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'javascript_xo_use_global')
        return ale#Var(a:buffer, 'javascript_xo_executable')
    endif

    return ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/xo',
    \   ale#Var(a:buffer, 'javascript_xo_executable')
    \)
endfunction

function! ale_linters#javascript#xo#GetCommand(buffer) abort
    return ale#Escape(ale_linters#javascript#xo#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'javascript_xo_options')
    \   . ' --reporter unix --stdin --stdin-filename %s'
endfunction

function! ale_linters#javascript#xo#Handle(buffer, lines) abort
    " xo uses eslint and the output format is the same
    return ale_linters#javascript#eslint#Handle(a:buffer, a:lines)
endfunction

call ale#linter#Define('javascript', {
\   'name': 'xo',
\   'executable_callback': 'ale_linters#javascript#xo#GetExecutable',
\   'command_callback': 'ale_linters#javascript#xo#GetCommand',
\   'callback': 'ale_linters#javascript#xo#Handle',
\})
