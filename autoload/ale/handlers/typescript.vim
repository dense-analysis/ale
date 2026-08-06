call ale#Set('typescript_tsc_executable', 'tsc')
call ale#Set('typescript_lsp_project_root', '')

function! ale#handlers#typescript#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'typescript_tsc', [
    \   'node_modules/typescript/bin/tsc',
    \   '.yarn/sdks/typescript/bin/tsc',
    \   'node_modules/.bin/tsc',
    \])
endfunction

function! ale#handlers#typescript#GetProjectRoot(buffer) abort
    let l:project_root = ale#Var(a:buffer, 'typescript_lsp_project_root')

    if !empty(l:project_root)
        return l:project_root
    endif

    let l:possible_project_roots = [
    \   'tsconfig.json',
    \   'package.json',
    \   '.git',
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

