" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for integrating with Python linters.

let g:ale_virtualenv_dir_names = get(g:, 'ale_virtualenv_dir_names', [
\   '.env',
\   'env',
\   've-py3',
\   've',
\   'virtualenv',
\])

" Given a buffer number, find the project root directory for Python.
" The root directory is defined as the first directory found while searching
" upwards through paths, including the current directory, until a path
" containing no __init__.py files is found.
function! ale#python#FindProjectRoot(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        if !filereadable(l:path . '/__init__.py')
            return l:path
        endif
    endfor

    return ''
endfunction

" Given a buffer number, find a virtualenv path for Python.
function! ale#python#FindVirtualenv(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        for l:dirname in ale#Var(a:buffer, 'virtualenv_dir_names')
            let l:venv_dir = l:path . '/' . l:dirname

            if filereadable(l:venv_dir . '/bin/activate')
                return l:venv_dir
            endif
        endfor
    endfor

    return ''
endfunction

" Given a buffer number and a command name, find the path to the executable.
" First search on a virtualenv for Python, if nothing is found, try the global
" command. Returns an empty string if cannot find the executable
function! ale#python#FindExecutable(buffer, base_var_name, path_list) abort
    if ale#Var(a:buffer, a:base_var_name . '_use_global')
        return ale#Var(a:buffer, a:base_var_name . '_executable')
    endif

    let l:virtualenv = ale#python#FindVirtualenv(a:buffer)

    if !empty(l:virtualenv)
        for l:path in a:path_list
            let l:ve_executable = l:virtualenv . l:path

            if executable(l:ve_executable)
                return l:ve_executable
            endif
        endfor
    endif

    let l:global_executable = ale#Var(a:buffer, a:base_var_name . '_executable')

    if executable(l:global_executable)
        return l:global_executable
    endif

    return ''
endfunction
