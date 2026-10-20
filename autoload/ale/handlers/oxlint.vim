" Author: Jeff Miccolis <jeff@miccolis.net>

call ale#Set('javascript_oxlint_executable', 'oxlint')
call ale#Set('javascript_oxlint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('javascript_oxlint_options', {})

function! ale#handlers#oxlint#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'javascript_oxlint', [
    \   'node_modules/.bin/oxlint',
    \])
endfunction

function! ale#handlers#oxlint#GetProjectRoot(buffer) abort
    let l:possible_project_roots = [
    \   '.oxlintrc.json',
    \   '.oxlintrc.jsonc',
    \   'oxlint.config.ts',
    \   'oxlint.config.mts',
    \   'package.json',
    \   bufname(a:buffer),
    \]

    for l:possible_root in l:possible_project_roots
        let l:project_root = ale#path#FindNearestFile(a:buffer, l:possible_root)

        if empty(l:project_root)
            let l:project_root = ale#path#FindNearestDirectory(a:buffer, l:possible_root)
        endif

        if !empty(l:project_root)
            " dir:p expands to /full/path/to/dir/ whereas
            " file:p expands to /full/path/to/file (no trailing slash)
            " Appending '/' ensures that :h:h removes the path's last segment
            " regardless of whether it is a directory or not.
            return fnamemodify(l:project_root . '/', ':p:h:h')
        endif
    endfor

    return ''
endfunction

function! ale#handlers#oxlint#GetInitializationOptions(buffer) abort
    let l:options = ale#Var(a:buffer, 'javascript_oxlint_options')
    return l:options
endfunction
