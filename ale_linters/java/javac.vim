" Author: farenjihn <farenjihn@gmail.com>, w0rp <devw0rp@gmail.com>
" Description: Lints java files using javac

let g:ale_java_javac_options = get(g:, 'ale_java_javac_options', '')
let g:ale_java_javac_classpath = get(g:, 'ale_java_javac_classpath', '')

function! ale_linters#java#javac#GetCommand(buffer) abort
    let l:cp_option = !empty(ale#Var(a:buffer, 'java_javac_classpath'))
    \   ?  '-cp ' . ale#Var(a:buffer, 'java_javac_classpath')
    \   : ''

    " Create .class files in a temporary directory, which we will delete later.
    let l:class_file_directory = ale#engine#CreateDirectory(a:buffer)

    return 'javac -Xlint '
    \ . l:cp_option
    \ . ' -d ' . fnameescape(l:class_file_directory)
    \ . ' ' . ale#Var(a:buffer, 'java_javac_options')
    \ . ' %t'
endfunction

function! ale_linters#java#javac#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " Main.java:13: warning: [deprecation] donaught() in Testclass has been deprecated
    " Main.java:16: error: ';' expected

    let l:pattern = '^.*\:\(\d\+\):\ \(.*\):\(.*\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
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
