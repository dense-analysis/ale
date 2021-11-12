" Author: Arizard <https://github.com/Arizard>
" Description: PHPactor integration for ALE

call ale#Set('php_phpactor_executable', 'phpactor')

function! ale_linters#php#phpactor#GetProjectRoot(buffer) abort
    let l:composer_path = ale#path#FindNearestFile(a:buffer, 'composer.json')

    if (!empty(l:composer_path))
        return fnamemodify(l:composer_path, ':h')
    endif

    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    return !empty(l:git_path) ? fnamemodify(l:git_path, ':h:h') : ''
endfunction

execute 'echo' 'hello world'

call ale#linter#Define('php', {
\   'name': 'phpactor',
\   'lsp': 'stdio',
\   'executable': 'phpactor',
\   'command': '%e language-server',
\   'project_root': function('ale_linters#php#phpactor#GetProjectRoot'),
\})
