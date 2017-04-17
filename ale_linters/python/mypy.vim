" Author: Keith Smiley <k@keith.so>, w0rp <devw0rp@gmail.com>
" Description: mypy support for optional python typechecking

let g:ale_python_mypy_options = get(g:, 'ale_python_mypy_options', '')

function! ale_linters#python#mypy#GetCommand(buffer) abort
    let l:automatic_stubs_dir = ale#path#FindNearestDirectory(a:buffer, 'stubs')
    " TODO: Add Windows support
    let l:automatic_stubs_command = (has('unix') && !empty(l:automatic_stubs_dir))
    \   ?  'MYPYPATH=' . l:automatic_stubs_dir . ' '
    \   : ''

    return 'mypy --show-column-numbers '
    \   . ale#Var(a:buffer, 'python_mypy_options')
    \   . ' %t'
endfunction

let s:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'

function! ale_linters#python#mypy#Handle(buffer, lines) abort
    " Look for lines like the following:
    "
    " file.py:4: error: No library stub file for module 'django.db'
    "
    " Lines like these should be ignored below:
    "
    " file.py:4: note: (Stub files are from https://github.com/python/typeshed)
    let l:pattern = '^' . s:path_pattern . ':\(\d\+\):\?\(\d\+\)\?: \([^:]\+\): \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:match[4] =~# 'Stub files are from'
            " The lines telling us where to get stub files from make it so
            " we can't read the actual errors, so exclude them.
            continue
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3] =~# 'error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'mypy',
\   'executable': 'mypy',
\   'command_callback': 'ale_linters#python#mypy#GetCommand',
\   'callback': 'ale_linters#python#mypy#Handle',
\})
