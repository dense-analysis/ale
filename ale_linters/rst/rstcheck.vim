" Author: John Nduli https://github.com/jnduli
" Description: Rstcheck for reStructuredText files

let g:ale_lint_delay = 1000

function! ale_linters#rst#rstcheck#Handle(buffer, lines) abort
    " matches: 'bad_rst.rst:1: (SEVERE/4) Title overline & underline
    " mismatch.'
    let l:pattern = '\v^\S*:(\d*): \(([a-zA-Z]*)/\d*\) (.+)$'
    let l:output = []
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
                    \   'lnum': l:match[1] + 0,
                    \   'col': 0,
                    \   'type': l:match[2] is# 'SEVERE' ? 'E' : 'W',
                    \   'text': l:match[3],
                    \})
    endfor

    return l:output
endfunction


call ale#linter#Define('rst', {
            \   'name': 'rstcheck',
            \   'executable': 'rstcheck',
            \   'command': 'rstcheck %t',
            \   'callback': 'ale_linters#rst#rstcheck#Handle',
            \   'output_stream': 'both',
            \})
