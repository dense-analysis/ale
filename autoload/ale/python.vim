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
