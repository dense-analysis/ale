" Author: John Jackson <john@johnridesa.bike>
" Description: The official language server for ReScript.

call ale#Set('rescript_language_server_executable', 'rescript-language-server')
call ale#Set(
\   'rescript_language_server_use_global',
\   get(g:, 'ale_use_global_executables', v:true),
\ )

function! s:GetProjectRoot(buffer) abort
    let l:config_file = ale#path#FindNearestFile(a:buffer, 'rescript.json')

    return !empty(l:config_file) ? fnamemodify(l:config_file, ':h') : ''
endfunction

call ale#linter#Define('rescript', {
\   'name': 'rescript_language_server',
\   'lsp': 'stdio',
\   'executable': {b -> ale#path#FindExecutable(b, 'rescript_language_server', [
\       'node_modules/.bin/rescript-language-server'
\   ])},
\   'command': '%e --stdio',
\   'project_root': function('s:GetProjectRoot'),
\})
