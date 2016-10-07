" Author: Spencer Wood <https://github.com/scwood>
" Description: This file adds support for checking PHP with php-cli

if exists('g:loaded_ale_linters_php_php')
    finish
endif

let g:loaded_ale_linters_php_php = 1

function! ale_linters#php#php#Handle(buffer, lines)
    " Matches patterns like the following:
    "
    " Parse error: parse error in - on line 7
    let pattern = 'Parse error: \(.\+\) on line \(\d\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[2] + 0,
        \   'vcol': 0,
        \   'col': 1,
        \   'text': l:match[1],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('php', {
\   'name': 'php',
\   'executable': 'php',
\   'output_stream': 'both',
\   'command': 'php -l --',
\   'callback': 'ale_linters#php#php#Handle',
\})
