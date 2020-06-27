" Author: The Tremor Team <opensource@wayfair.com>
" Description: Language server for tremor's languages

call ale#Set('tremor_language_server_executable', 'tremor-language-server')

function! ale_linters#tremor#tremor_language_server#GetCommand(buffer) abort
    return '%e --language ' . &filetype
endfunction

function! ale_linters#tremor#tremor_language_server#GetProjectRoot(buffer) abort
    return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

call ale#linter#Define('tremor', {
\   'name': 'tremor_language_server',
\   'aliases': ['tremor-language-server', 'trill'],
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'tremor_language_server_executable')},
\   'command': function('ale_linters#tremor#tremor_language_server#GetCommand'),
\   'project_root': function('ale_linters#tremor#tremor_language_server#GetProjectRoot'),
\})
