" Author: Sukima <suki@tritarget.org>
" Description: glint integration for ALE

call ale#Set('glimmer_glint_executable', 'glint-language-server')
call ale#Set('glimmer_glint_config_path', '')
call ale#Set('glimmer_glint_use_global', get(g:, 'ale_use_global_executables', 0))

" Reusing ale#handlers#tsserver#GetProjectRoot is intentional
call ale#linter#Define('glimmer', {
\   'name': 'glint',
\   'lsp': 'stdio',
\   'executable': {b -> ale#path#FindExecutable(b, 'glimmer_glint', [
\       'node_modules/.bin/glint-language-server',
\   ])},
\   'command': '%e',
\   'project_root': function('ale#handlers#tsserver#GetProjectRoot'),
\   'language': '',
\})
