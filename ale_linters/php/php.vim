" Author: Spencer Wood <https://github.com/scwood>
" Description: This file adds support for checking PHP with php-cli

function! ale_linters#php#php#Handle(buffer, lines)
    " Matches patterns like the following:
    "
    " Parse error: parse error in - on line 7
    let l:pattern = 'Parse error:\s\+\(.\+\) on line \(\d\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[2] + 0,
        \   'vcol': 0,
        \   'col': 1,
        \   'text': l:match[1],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'php',
\   'executable': 'php',
\   'output_stream': 'both',
\   'command': 'php -l -d display_errors=1 --',
\   'callback': 'ale_linters#php#php#Handle',
\})
