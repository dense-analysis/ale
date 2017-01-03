" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl with perl critic

function! ale_linters#perl#perlcritic#Handle(buffer, lines)
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[3]
        let l:column = 1
        let l:text = l:match[1]
        let l:type = 'E'

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'vcol': 0,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \   'nr': -1,
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
