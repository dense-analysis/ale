" Author: Daniel Lupu <lupu.daniel.f@gmail.com>
" Description: xo for JavaScript files

call ale#Set('javascript_xo_executable', 'xo')
call ale#Set('javascript_xo_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('javascript_xo_options', '')

function! ale#handlers#xo#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_xo', [
    \   'node_modules/.bin/xo',
    \])
endfunction

function! ale#handlers#xo#GetCommand(buffer) abort
    return ale#Escape(ale#handlers#xo#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'javascript_xo_options')
    \   . ' --reporter unix --stdin --stdin-filename %s'
endfunction
