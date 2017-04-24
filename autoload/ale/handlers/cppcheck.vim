" Description: Handle errors for cppcheck.

function! ale#handlers#cppcheck#HandleCppCheckFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    " [test.cpp:5]: (error) Array 'a[10]' accessed at index 10, which is out of bounds
    let l:pattern = '^\[.\{-}:\(\d\+\)\]: (\(.\{-}\)) \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': 0,
        \   'text': l:match[3] . ' (' . l:match[2] . ')',
        \   'type': l:match[2] ==# 'error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction
