" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl with perl critic

function! ale_linters#perl#perlcritic#Handle(buffer, lines) abort
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[3]
        let l:text = l:match[1]
        let l:type = 'E'

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'text': l:text,
        \   'type': l:type,
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
