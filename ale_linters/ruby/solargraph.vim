" Author: Horacio Sanson - https://github.com/hsanson
" Description: Solargraph Language Server https://solargraph.org/

call ale#Set('ruby_solargraph_host', '127.0.0.1')
call ale#Set('ruby_solargraph_port', '7658')

function! ale_linters#ruby#solargraph#GetAddress(buffer) abort
    let l:host = ale#Var(a:buffer, 'ruby_solargraph_host')
    let l:port = ale#Var(a:buffer, 'ruby_solargraph_port')

    return l:host . ':' . l:port
endfunction

call ale#linter#Define('ruby', {
\   'name': 'solargraph',
\   'lsp': 'socket',
\   'address_callback': 'ale_linters#ruby#solargraph#GetAddress',
\   'language': 'ruby',
\   'project_root_callback': 'ale#ruby#FindProjectRoot'
\})
