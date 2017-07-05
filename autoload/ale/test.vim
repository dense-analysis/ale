" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for making testing ALE easier.
"
" This file should not typically be loaded during the normal execution of ALE.

" Change the filename for the current buffer using a relative path to
" the script without running autocmd commands.
"
" If a g:dir variable is set, it will be used as the path to the directory
" containing the test file.
function! ale#test#SetFilename(path) abort
    let l:dir = get(g:, 'dir', '')

    if empty(l:dir)
        let l:dir = getcwd()
    endif

    silent noautocmd execute 'file ' . fnameescape(ale#path#Simplify(l:dir . '/' . a:path))
endfunction
