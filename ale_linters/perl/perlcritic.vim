" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl with perl critic

function! ale_linters#perl#perlcritic#Handle(buffer, lines) abort
    let l:pattern = '\(\d\+\):\(\d\+\) \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'col': l:match[2],
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('perl', {
\   'name': 'perlcritic',
\   'executable': 'perlcritic',
\   'output_stream': 'stdout',
\   'command': "perlcritic --verbose '%l:%c %m\n' --nocolor",
\   'callback': 'ale_linters#perl#perlcritic#Handle',
\})
