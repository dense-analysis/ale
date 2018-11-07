" Author: Matt Brown <https://github.com/muglug>
" Description: plugin for Psalm, static analyzer for PHP

call ale#Set('psalm_langserver_executable', 'psalm-language-server')
call ale#Set('psalm_langserver_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#php#psalm#GetProjectRoot(buffer) abort
    let l:composer_path = ale#path#FindNearestFile(a:buffer, 'composer.json')

    return !empty(l:composer_path) ? fnamemodify(l:composer_path, ':h') : ''
endfunction

call ale#linter#Define('php', {
\   'name': 'psalm',
\   'lsp': 'stdio',
\   'executable_callback': ale#node#FindExecutableFunc('psalm_langserver', [
\       'vendor/bin/psalm-language-server',
\   ]),
\   'command': '%e',
\   'project_root_callback': 'ale_linters#php#psalm#GetProjectRoot',
\})
