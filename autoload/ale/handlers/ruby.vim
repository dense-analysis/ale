" Author: Matthias Guenther https://wikimatze.de
"
" Description: This file implements handlers specific to Ruby.

function! s:HandleErbError(buffer, lines) abort
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

function! ale#handlers#ruby#HandleErbFormationAsError(buffer, lines) abort
    return s:HandleErbError(a:buffer, a:lines)
endfunction

