" Author: Don Isaac
" Description: A linter for the Zig programming language

call ale#Set('zig_zlint_executable', 'zlint')

function! ale_linters#zig#zlint#Handle(buffer, lines) abort
    " GitHub Actions format: ::severity file=file,line=line,col=col,title=code::message
    let l:pattern = '::\([a-z]\+\) file=\([^,]\+\),line=\(\d\+\),col=\(\d\+\),title=\([^:]\+\)::\(.*\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': l:match[2],
        \   'lnum': str2nr(l:match[3]),
        \   'col': str2nr(l:match[4]),
        \   'text': l:match[6],
        \   'type': l:match[1] =~? 'error\|fail' ? 'E' : 'W',
        \   'code': l:match[5],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('zig', {
\   'name': 'zlint',
\   'executable': {b -> ale#Var(b, "zig_zlint_executable")},
\   'command': '%e %s -f gh',
\   'callback': 'ale_linters#zig#zlint#Handle',
\})
