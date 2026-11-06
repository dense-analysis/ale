" Author: MTDL9 <https://github.com/MTDL9>
" Description: Support for the Kotlin language server https://github.com/fwcd/KotlinLanguageServer

call ale#Set('kotlin_languageserver_executable', 'kotlin-language-server')

call ale#linter#Define('kotlin', {
\   'name': 'languageserver',
\   'aliaes': ['kotlin_language_server'],
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'kotlin_languageserver_executable')},
\   'command': '%e',
\   'language': 'kotlin',
\   'project_root': function('ale#kotlin#FindProjectRoot'),
\})
