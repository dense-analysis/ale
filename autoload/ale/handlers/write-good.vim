" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: Error handling for errors in the write-good format.

let g:ale_writegood_options = get(g:, 'ale_writegood_options', '')

function! s:HandleWriteGoodFormat(buffer, lines, type) abort
    let l:pattern = '\v[\^\s]+\n^(".*"\s.*)on\sline\s(\d+)\sat\scolumn\s(\d+)$\n-+$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'text': l:match[1],
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': a:type,
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#writegood#HandleAsWarning(buffer, lines) abort
    return s:HandleWriteGoodFormat(a:buffer, a:lines, 'W')
endfunction
