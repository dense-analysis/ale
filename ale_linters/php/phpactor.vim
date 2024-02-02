" Author: Arizard <https://github.com/Arizard>
" Description: PHPactor integration for ALE
" Note: initial code has been copied from langserver.vim

call ale#Set('php_phpactor_executable', 'phpactor')
call ale#Set('php_phpactor_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#php#phpactor#GetProjectRoot(buffer) abort
    let l:composer_path = ale#path#FindNearestFile(a:buffer, 'composer.json')
    let l:file_mappings = ale#GetFilenameMappings(a:buffer, 'phpactor')

    if (!empty(l:composer_path))
        let l:mapped_path = ale_linters#php#phpactor#Mapping(l:composer_path, l:file_mappings )

        return fnamemodify(l:mapped_path, ':h')
    endif

    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')
    let l:mapped_path = ale_linters#php#phpactor#Mapping(l:git_path, l:file_mappings )

    return !empty(l:mapped_path) ? fnamemodify(l:mapped_path, ':h:h') : ''
endfunction

function! ale_linters#php#phpactor#Mapping(filename, filename_mappings) abort
    if empty(a:filename_mappings)
        " No mapping found to return
        return a:filename
    endif

    for [l:mapping_from, l:mapping_to] in a:filename_mappings
        let l:mapping_from = ale#path#Simplify(l:mapping_from)

        if a:filename[:len(l:mapping_from) - 1] is# l:mapping_from
            return l:mapping_to
        endif
    endfor

    " No entry found to return
    return a:filename
endfunction

call ale#linter#Define('php', {
\   'name': 'phpactor',
\   'lsp': 'stdio',
\   'executable': {b -> ale#path#FindExecutable(b, 'php_phpactor', [
\       'vendor/bin/phpactor',
\       'phpactor'
\   ])},
\   'command': '%e language-server',
\   'project_root': function('ale_linters#php#phpactor#GetProjectRoot'),
\})
