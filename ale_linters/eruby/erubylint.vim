" Author: Matthias Guenther - https://wikimatze.de
" Description: erb-lint for eruby/erb files

function! ale_linters#eruby#erubylint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " -:17: syntax error, unexpected end-of-input, expecting keyword_end
     let l:pattern = '^-:\(\d\+\): \([^,]*\),\(.*\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'type': '',
        \   'text': l:match[2] . ':' . l:match[3]
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('eruby', {
\   'name': 'erubylint',
\   'executable': 'erb',
\    'output_stream': 'stderr',
\   'command': 'erb -P -x %t | ruby -c',
\   'callback': 'ale_linters#eruby#erubylint#Handle'
\})

