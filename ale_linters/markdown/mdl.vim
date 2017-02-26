" Author: Steve Dignam <steve@dignam.xyz>
" Description: Support for mdl, a markdown linter

function! ale_linters#markdown#mdl#Handle(buffer, lines) abort
    " matches: '(stdin):173: MD004 Unordered list style'
    let l:pattern = ':\(\d*\): \(.*\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': 0,
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
