" Author: soywod <clement.douin@posteo.net>
" Description: typescript-language-server integration for ALE

call ale#Set('javascript_tls_executable', 'typescript-language-server')
call ale#Set('javascript_tls_config_path', '')
call ale#Set('javascript_tls_use_global', get(g:, 'ale_use_global_executables', 0))

call ale#linter#Define('javascript', {
\   'name': 'tls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#node#FindExecutable(b, 'javascript_tls', [
\       'node_modules/.bin/typescript-language-server',
\   ])},
\   'command': '%e --stdio',
\   'project_root': {b -> fnamemodify(ale#path#FindNearestFile(b, 'package.json'), ':p:h')},
\   'language': '',
\})
