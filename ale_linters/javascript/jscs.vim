" Author: Chris Kyrouac - https://github.com/fijshion
" Description: jscs for JavaScript files

if exists('g:loaded_ale_linters_javascript_jscs')
    finish
endif

let g:loaded_ale_linters_javascript_jscs = 1

function! ale_linters#javascript#jscs#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " input:57:8: Unexpected token (57:8)
    let l:pattern = '^.\+:\(\d\+\):\(\d\+\): \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[3]
        let l:marker_parts = l:match[4]

        if len(l:marker_parts) == 2
            let l:text = l:text . ' (' . l:marker_parts[1] . ')'
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('javascript', 'javascript.jsx', {
\   'name': 'jscs',
\   'executable': 'jscs',
\   'command': 'jscs -r unix -n -',
\   'callback': 'ale_linters#javascript#jscs#Handle',
\})
