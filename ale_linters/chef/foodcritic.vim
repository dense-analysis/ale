" Author: Edward Larkey <edwlarkey@mac.com>
" Description: This file adds the foodcritic linter for Chef files.

function! ale_linters#chef#foodcritic#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " FC002: Avoid string interpolation where not required: httpd.rb:13
    let l:pattern = '^\(.\+:\s.\+\):\s\(.\+\):\(\d\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[1]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[3] + 0,
        \   'col': 0,
        \   'text': l:text,
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('chef', {
\   'name': 'foodcritic',
\   'executable': 'foodcritic',
\   'command': 'foodcritic %t',
\   'callback': 'ale_linters#chef#foodcritic#Handle',
\})

