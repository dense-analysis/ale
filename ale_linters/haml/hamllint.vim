" Author: Patrick Lewis - https://github.com/patricklewis
" Description: haml-lint for Haml files

function! ale_linters#haml#hamllint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " <path>:51 [W] RuboCop: Use the new Ruby 1.9 hash syntax.
    let l:pattern = '\v^.*:(\d+) \[([EW])\] (.+)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[3]
        let l:type = l:match[2]

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'text': l:text,
        \   'type': l:type
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('haml', {
\   'name': 'hamllint',
\   'executable': 'haml-lint',
\   'command': 'haml-lint %t',
\   'callback': 'ale_linters#haml#hamllint#Handle'
\})
