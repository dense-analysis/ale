" Author: TcM1911
" Description: A language server for Yara.

call ale#Set('yara_yls_executable', 'yls')

function! ale_linters#yara#yls#FindProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')

    return !empty(l:project_root) ? (ale#path#Upwards(l:project_root)[1]) : ''
endfunction

call ale#linter#Define('yara', {
\   'name': 'yls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'yara_yls_executable')},
\   'command': '%e -v',
\   'project_root': function('ale_linters#yara#yls#FindProjectRoot'),
\})
