" Author: Moritz Maxeiner <moritz@ucworks.org>
" Description: "dscanner for D files"

function! ale_linters#d#dscanner#DScannerCommand(buffer) abort
    return 'dscanner -S %t'
endfunction

function! ale_linters#d#dscanner#Handle(buffer, lines) abort
    let l:pattern = '^[^(]\+(\([0-9]\+\)\:\?\([0-9]*\))\[\([^\]]*\)\]: \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'col': l:match[2],
        \   'type': l:match[3] ==# 'warn' ? 'W' : 'E',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'dscanner',
\   'executable': 'dscanner',
\   'command_chain': [
\       {'callback': 'ale_linters#d#dscanner#DScannerCommand', 'output_stream': 'stdout'},
\   ],
\   'callback': 'ale_linters#d#dscanner#Handle',
\})
