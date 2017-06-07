" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing files with autopep8.

function! ale#fixers#autopep8#Fix(buffer) abort
    return {
    \   'command': 'autopep8 -'
    \}
endfunction
