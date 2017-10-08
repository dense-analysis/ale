" Author: diegoholiveira <https://github.com/diegoholiveira>
" Description: define a handler to php static analyzers

function! ale#handlers#php#StaticAnalyzerHandle(buffer, lines) abort
    " Matches against lines like the following:
    "
    " /path/to/some-filename.php:18 message
    let l:pattern = '^.*:\(\d\+\)\s\(.\+\)$'
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
