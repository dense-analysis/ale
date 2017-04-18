" Author: Spencer Wood <https://github.com/scwood>, Adriaan Zonnenberg <amz@adriaan.xyz>
" Description: This file adds support for checking PHP with php-cli

function! ale_linters#php#php#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " PHP Parse error:  syntax error, unexpected ';', expecting ']' in - on line 15
    let l:pattern = '\vPHP %(Fatal|Parse) error:\s+(.+unexpected ''(.+)%(expecting.+)@<!''.*|.+) in - on line (\d+)'

    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[3] + 0,
        \   'col': empty(l:match[2]) ? 0 : stridx(getline(l:match[3]), l:match[2]) + 1,
        \   'text': l:match[1],
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
