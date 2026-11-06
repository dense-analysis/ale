" Author: Paul Meinhardt <https://github.com/pmeinhardt>
" Description: Support for the official Kotlin language server https://github.com/Kotlin/kotlin-lsp

call ale#Set('kotlin_kotlin_lsp_executable', 'kotlin-lsp')

call ale#linter#Define('kotlin', {
\   'name': 'kotlin_lsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'kotlin_kotlin_lsp_executable')},
\   'command': '%e --stdio',
\   'language': 'kotlin',
\   'project_root': function('ale#kotlin#FindProjectRoot'),
\})
