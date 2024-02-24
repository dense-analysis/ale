" Author: Filip Gospodinov <f@gospodinov.ch>
" Description: biome for JavaScript files

call ale#linter#Define('javascript', {
\   'name': 'biome',
\   'lsp': 'stdio',
\   'executable': function('ale#handlers#biome#GetExecutable'),
\   'command': function('ale#handlers#biome#GetCommand'),
\   'project_root': function('ale#handlers#biome#GetProjectRoot'),
\})
