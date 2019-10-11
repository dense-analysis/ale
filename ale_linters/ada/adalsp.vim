" Author: Bartek Jasicki http://github.com/thindil
" Description: Support for Ada Language Server

call ale#Set('ada_lsp_executable', 'ada_language_server')

function! ale_linters#ada#adalsp#GetRootDirectory(buffer) abort
    return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

call ale#linter#Define('ada', {
\   'name': 'adalsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'ada_lsp_executable')},
\   'command': '%e',
\   'project_root': function('ale_linters#ada#adalsp#GetRootDirectory'),
\})
