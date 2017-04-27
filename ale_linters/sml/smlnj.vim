" Author: Paulo Alem    <paulo.alem@gmail.com>
" Description: Rudimentary SML checking with smlnj compiler

function! ale_linters#sml#smlnj#Handle(buffer, lines) abort
    " Try to match basic sml errors

    let l:out = []
    let l:pattern = '^.*\:\([0-9\.]\+\)\ \(\w\+\)\:\ \(.*\)'
    let l:pattern2 = '^.*\:\([0-9]\+\)\.\?\([0-9]\+\).* \(\(Warning\|Error\): .*\)'

    for l:line in a:lines
        let l:match2 = matchlist(l:line, l:pattern2)

        if len(l:match2) != 0
          call add(l:out, {
          \   'bufnr': a:buffer,
          \   'lnum': l:match2[1] + 0,
          \   'col' : l:match2[2] - 1,
          \   'text': l:match2[3],
          \   'type': l:match2[3] =~# '^Warning' ? 'W' : 'E',
          \})
          continue
        endif

        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) != 0
          call add(l:out, {
          \   'bufnr': a:buffer,
          \   'lnum': l:match[1] + 0,
          \   'text': l:match[2] . ': ' . l:match[3],
          \   'type': l:match[2] ==# 'error' ? 'E' : 'W',
          \})
          continue
        endif

    endfor

    return l:out
endfunction

call ale#linter#Define('sml', {
\   'name': 'smlnj',
\   'executable': 'sml',
\   'command': 'sml',
\   'callback': 'ale_linters#sml#smlnj#Handle',
\})
