" Author: Koni Marti <koni.marti@gmail.com>
" Description: A Language Server implementation for C3

call ale#Set('c3_c3lsp_executable', 'c3lsp')
call ale#Set('c3_c3lsp_options', '')
call ale#Set('c3_c3lsp_init_options', {})

function! ale_linters#c3#c3lsp#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'c3_c3lsp_executable')

    return ale#Escape(l:executable) . ale#Pad(ale#Var(a:buffer, 'c3_c3lsp_options'))
endfunction


call ale#linter#Define('c3', {
\   'name': 'c3lsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'c3_c3lsp_executable')},
\   'command': function('ale_linters#c3#c3lsp#GetCommand'),
\   'project_root': function('ale#handlers#c3lsp#GetProjectRoot'),
\   'lsp_config': {b -> ale#handlers#c3lsp#GetInitOpts(b, 'c3_c3lsp_init_options')},
\})
