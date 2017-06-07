" Author: w0rp <devw0rp@gmail.com>
" Description: Generic functions for fixing files with.

function! ale#fixers#generic#RemoveTrailingBlankLines(buffer, lines) abort
    let l:end_index = len(a:lines) - 1

    while l:end_index > 0 && empty(a:lines[l:end_index])
        let l:end_index -= 1
    endwhile

    return a:lines[:l:end_index]
endfunction
