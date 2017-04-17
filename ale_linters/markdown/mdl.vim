" Author: Steve Dignam <steve@dignam.xyz>
" Description: Support for mdl, a markdown linter

function! ale_linters#markdown#mdl#Handle(buffer, lines) abort
    " matches: '(stdin):173: MD004 Unordered list style'
    let l:pattern = ':\(\d*\): \(.*\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('markdown', {
\   'name': 'mdl',
\   'executable': 'mdl',
\   'command': 'mdl',
\   'callback': 'ale_linters#markdown#mdl#Handle'
\})
