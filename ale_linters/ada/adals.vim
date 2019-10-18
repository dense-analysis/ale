" Author: Bartek Jasicki http://github.com/thindil
" Description: Support for Ada Language Server

call ale#Set('ada_adals_executable', 'ada_language_server')

function! ale_linters#ada#adals#GetRootDirectory(buffer) abort
    return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

call ale#linter#Define('ada', {
\   'name': 'adals',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'ada_adals_executable')},
\   'command': '%e',
\   'project_root': function('ale_linters#ada#adals#GetRootDirectory'),
\})
