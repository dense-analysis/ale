" Author: aqui18 <https://github.com/aqui18>
" Description: This file adds support for checking Racket code with raco.

function! ale_linters#racket#raco#Handle(buffer, lines) abort
    " Matches patterns 
    " <file>:<line>:<column> <message>
    " eg:
    " info.rkt:4:0: infotab-module: not a well-formed definition  
    let l:pattern = '^.\+:\(\d\+\):\(\d\+\) \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('racket', {
\   'name': 'raco',
\   'executable': 'raco',
\   'output_stream': 'stderr',
\   'command': 'raco expand ',
\   'callback': 'ale_linters#racket#raco#Handle',
\})
