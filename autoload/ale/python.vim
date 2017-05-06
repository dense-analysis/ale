" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for integrating with Python linters.

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
        let l:matches = globpath(l:path, '*/bin/activate', 0, 1)

        if !empty(l:matches)
            return fnamemodify(l:matches[-1], ':h:h')
        endif
    endfor

    return ''
endfunction
