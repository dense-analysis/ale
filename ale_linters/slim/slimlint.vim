" Author: Markus Doits - https://github.com/doits
" Description: slim-lint for Slim files, based on hamllint.vim

function! ale_linters#slim#slimlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " <path>:5 [W] LineLength: Line is too long. [150/120]
    let l:pattern = '\v^.*:(\d+) \[([EW])\] (.+)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'type': l:match[2],
        \   'text': l:match[3]
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('slim', {
\   'name': 'slimlint',
\   'executable': 'slim-lint',
\   'command': 'slim-lint %t',
\   'callback': 'ale_linters#slim#slimlint#Handle'
\})
