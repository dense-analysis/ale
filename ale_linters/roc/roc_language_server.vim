" Author: Benjamin Block <https://github.com/benjamindblock>
" Description: A language server for Roc.

function! ale_linters#roc#roc_language_server#GetProjectRoot(buffer) abort
    let l:roc_main_file = ale#path#FindNearestFile(a:buffer, 'main.roc')

    if !empty(l:roc_main_file)
        return fnamemodify(l:roc_main_file, ':p:h')
    else
        return fnamemodify('', ':h')
    endif
endfunction

call ale#Set('roc_roc_language_server_executable', 'roc_language_server')
call ale#Set('roc_roc_language_server_config', {})

call ale#linter#Define('roc', {
\   'name': 'roc_language_server',
\   'lsp': 'stdio',
\   'language': 'roc',
\   'lsp_config': {b -> ale#Var(b, 'roc_roc_language_server_config')},
\   'executable': {b -> ale#Var(b, 'roc_roc_language_server_executable')},
\   'command': '%e',
\   'project_root': function('ale_linters#roc#roc_language_server#GetProjectRoot'),
\})
