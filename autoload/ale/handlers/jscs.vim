
function! ale#handlers#jscs#Handle(buffer, lines) abort
    " Matches patterns looking like the following
    "
    " foobar.js: line 2, col 1, Expected indentation of 1 characters
    "
    let l:pattern = '^.*:\s\+line \(\d\+\),\s\+col\s\+\(\d\+\),\s\+\(.*\)$'
    let l:output = []
    let l:m = ale#util#GetMatches(a:lines, [l:pattern])

    for l:match in l:m
        let l:text = l:match[3]

        let l:obj = {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3]
        \}

        call add(l:output, l:obj)
    endfor

    return l:output
endfunction
