" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl with perl critic

if exists('g:loaded_ale_linters_perl_perlcritic')
    finish
endif

let g:loaded_ale_linters_perl_perlcritic = 1
function! ale_linters#perl#perlcritic#Handle(buffer, lines)
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

call ale#linter#define('perl', {
\   'name': 'perlcritic',
\   'executable': 'perlcritic',
\   'output_stream': 'sdtout',
\   'command': 'perlcritic --verbose 3 --nocolor',
\   'callback': 'ale_linters#perl#perlcritic#Handle',
\})
