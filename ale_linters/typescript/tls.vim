" Author: soywod <clement.douin@posteo.net>
" Description: typescript-language-server integration for ALE

call ale#Set('typescript_tls_executable', 'typescript-language-server')
call ale#Set('typescript_tls_config_path', '')
call ale#Set('typescript_tls_use_global', get(g:, 'ale_use_global_executables', 0))

call ale#linter#Define('typescript', {
\   'name': 'tls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#node#FindExecutable(b, 'typescript_tls', [
\       'node_modules/.bin/typescript-language-server',
\   ])},
\   'command': '%e --stdio',
\   'project_root': function('ale#handlers#tsserver#GetProjectRoot'),
\   'language': '',
\})
