" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl syntax

if exists('g:loaded_ale_linters_perl_perlcritic')
    finish
endif

let g:loaded_ale_linters_perl_perl = 1
function! ale_linters#perl#perl#Handle(buffer, lines)
    let pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[3]
        let column = 1
        let text = l:match[1]
        let type = 'E'

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': column,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#Define('perl', {
\   'name': 'perl',
\   'executable': 'perl',
\   'output_stream': 'both',
\   'command': 'perl -X -c -Mwarnings -Ilib',
\   'callback': 'ale_linters#perl#perl#Handle',
\})
