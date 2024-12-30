" Author: Koni Marti <koni.marti@gmail.com>
" Description: A Language Server implementation for C3

call ale#Set('c3_c3lsp_executable', 'c3lsp')
call ale#Set('c3_c3lsp_init_options', {})

call ale#linter#Define('c3', {
\   'name': 'c3lsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'c3_c3lsp_executable')},
\   'command': '%e',
\   'project_root': function('ale#handlers#c3lsp#GetProjectRoot'),
\   'lsp_config': {b -> ale#handlers#c3lsp#GetInitOpts(b, 'c3_c3lsp_init_options')},
\})
