call ale#Set('typescript_tsc_config_path', '')
call ale#Set('typescript_tsc_use_global', get(g:, 'ale_use_global_executables', 0))

call ale#linter#Define('typescript', {
\   'name': 'tsc',
\   'lsp': 'stdio',
\   'executable': function('ale#handlers#typescript#GetExecutable'),
\   'command': '%e --lsp --stdio',
\   'project_root': function('ale#handlers#typescript#GetProjectRoot'),
\})
