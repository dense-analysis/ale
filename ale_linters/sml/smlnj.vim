" Author: Paulo Alem    <paulo.alem@gmail.com>
" Description: Rudimentary SML checking with smlnj compiler

if exists('g:loaded_ale_sml_smlnj_checker')
    finish
endif

let g:loaded_ale_sml_smlnj_checker = 1

function! ale_linters#sml#smlnj#Handle(buffer, lines) abort
    " Try to match basic sml errors

    let l:out = []
    let l:pattern = '^.*\:\([0-9\.]\+\)\ \(\w\+\)\:\ \(.*\)'

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:out, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': 1,
        \   'text': l:match[2] . ': ' . l:match[3],
        \   'type': l:match[2] ==# 'error' ? 'E' : 'W',
        \})
    endfor

    return l:out
endfunction

call g:ale#linter#Define('sml', {
\   'name': 'smlnj',
\   'executable': 'sml',
\   'command': 'sml',
\   'callback': 'ale_linters#sml#smlnj#Handle',
\})
