" Author: Spencer Wood <https://github.com/scwood>
" Description: This file adds support for checking PHP with php-cli

function! ale_linters#php#php#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " PHP Parse error:  syntax error, unexpected ';', expecting ']' in - on line 15
    let l:pattern = '\vParse error:\s+(.+unexpected ''(.+)%(expecting.+)@<!''.*|.+) in - on line (\d+)'

    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[3] + 0,
        \   'col': empty(l:match[2]) ? 0 : stridx(getline(l:match[3]), l:match[2]) + 1,
        \   'text': l:match[1],
        \   'type': 'E',
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
