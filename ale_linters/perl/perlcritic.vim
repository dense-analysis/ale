" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl with perl critic

function! ale_linters#perl#perlcritic#Handle(buffer, lines) abort
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'text': l:match[1],
        \   'lnum': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('perl', {
\   'name': 'perlcritic',
\   'executable': 'perlcritic',
\   'output_stream': 'stdout',
\   'command': 'perlcritic --verbose 3 --nocolor',
\   'callback': 'ale_linters#perl#perlcritic#Handle',
\})
