" Author: Eric Stern <eric@ericstern.com>
" Description: PHP Language server integration for ALE

let g:ale_php_project_root_markers = get(g:, 'ale_php_project_root_markers', ['.git', '.hg', '.svn', 'composer.json'])

call ale#Set('php_langserver_executable', 'php-language-server.php')
call ale#Set('php_langserver_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#php#langserver#GetProjectRoot(buffer) abort
    let l:project_path = ale#path#FindNearestMarker(a:buffer, g:ale_php_project_root_markers)
    return !empty(l:project_path) ? fnamemodify(l:project_path, ':h') : getcwd()
endfunction

call ale#linter#Define('php', {
\   'name': 'langserver',
\   'lsp': 'stdio',
\   'executable_callback': ale#node#FindExecutableFunc('php_langserver', [
\       'vendor/bin/php-language-server.php',
\   ]),
\   'command': 'php %e',
\   'project_root_callback': 'ale_linters#php#langserver#GetProjectRoot',
\})
