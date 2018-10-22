" Author: Matt Brown <https://github.com/muglug>
" Description: plugin for Psalm, static analyzer for PHP

call ale#Set('php_psalm_lsp_executable', 'psalm-language-server')
call ale#Set('php_psalm_lsp_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#php#psalm_lsp#GetProjectRoot(buffer) abort
    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    return !empty(l:git_path) ? fnamemodify(l:git_path, ':h:h') : ''
endfunction

call ale#linter#Define('php', {
\   'name': 'psalm_lsp',
\   'lsp': 'stdio',
\   'executable_callback': ale#node#FindExecutableFunc('php_psalm_lsp', [
\       'vendor/bin/psalm-language-server',
\   ]),
\   'command': '%e',
\   'project_root_callback': 'ale_linters#php#psalm_lsp#GetProjectRoot',
\})