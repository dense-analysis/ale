" Author: Patrick Lewis - https://github.com/patricklewis
" Description: haml-lint for Haml files

function! ale_linters#eruby#erubylint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " <path>:51 [W] RuboCop: Use the new Ruby 1.9 hash syntax.
     let l:pattern = '^-:\(\d\+\): \([^,]*\),\(.*\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'type': "",
        \   'text': l:match[2] . ':' . l:match[3]
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('eruby', {
\   'name': 'erubylint',
\   'executable': 'erb',
\   'command': 'erb -P -x %t | ruby -c 2>&1',
\   'callback': 'ale_linters#eruby#erubylint#Handle'
\})


