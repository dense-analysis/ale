" Author: farenjihn <farenjihn@gmail.com>, w0rp <devw0rp@gmail.com>
" Description: Lints java files using javac

let g:ale_java_javac_options = get(g:, 'ale_java_javac_options', '')
let g:ale_java_javac_classpath = get(g:, 'ale_java_javac_classpath', '')

function! ale_linters#java#javac#GetCommand(buffer) abort
    let l:cp_option = !empty(g:ale_java_javac_classpath)
    \   ?  '-cp ' . g:ale_java_javac_classpath
    \   : ''

    return 'javac -Xlint '
    \ . l:cp_option
    \ . ' ' . g:ale_java_javac_options
    \ . ' %t'
endfunction

function! ale_linters#java#javac#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " Main.java:13: warning: [deprecation] donaught() in Testclass has been deprecated
    " Main.java:16: error: ';' expected

    let l:pattern = '^.*\:\(\d\+\):\ \(.*\):\(.*\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': 1,
        \   'text': l:match[2] . ':' . l:match[3],
        \   'type': l:match[2] ==# 'error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('java', {
\   'name': 'javac',
\   'output_stream': 'stderr',
\   'executable': 'javac',
\   'command_callback': 'ale_linters#java#javac#GetCommand',
\   'callback': 'ale_linters#java#javac#Handle',
\})
