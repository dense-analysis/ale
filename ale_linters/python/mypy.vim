" Author: Keith Smiley <k@keith.so>, w0rp <devw0rp@gmail.com>
" Description: mypy support for optional python typechecking

let g:ale_python_mypy_executable =
\   get(g:, 'ale_python_mypy_executable', 'mypy')
let g:ale_python_mypy_options = get(g:, 'ale_python_mypy_options', '')
let g:ale_python_mypy_use_global = get(g:, 'ale_python_mypy_use_global', 0)

function! ale_linters#python#mypy#GetExecutable(buffer) abort
    return ale#python#FindExecutable(a:buffer, 'python_mypy', ['mypy'])
endfunction

function! ale_linters#python#mypy#GetCommand(buffer) abort
    let l:project_root = ale#python#FindProjectRoot(a:buffer)
    let l:cd_command = !empty(l:project_root)
    \   ? ale#path#CdString(l:project_root)
    \   : ''
    let l:executable = ale_linters#python#mypy#GetExecutable(a:buffer)

    return l:cd_command
    \   . ale#Escape(l:executable)
    \   . ' --show-column-numbers '
    \   . ale#Var(a:buffer, 'python_mypy_options')
    \   . ' --shadow-file %s %t %s'
endfunction

function! ale_linters#python#mypy#Handle(buffer, lines) abort
    " Look for lines like the following:
    "
    " file.py:4: error: No library stub file for module 'django.db'
    "
    " Lines like these should be ignored below:
    "
    " file.py:4: note: (Stub files are from https://github.com/python/typeshed)
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):?(\d+)?: (error|warning): (.+)$'
    let l:output = []
    let l:buffer_filename = expand('#' . a:buffer . ':p')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:buffer_filename[-len(l:match[1]):] !=# l:match[1]
            continue
        endif

        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': l:match[4] =~# 'error' ? 'E' : 'W',
        \   'text': l:match[5],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'mypy',
\   'executable_callback': 'ale_linters#python#mypy#GetExecutable',
\   'command_callback': 'ale_linters#python#mypy#GetCommand',
\   'callback': 'ale_linters#python#mypy#Handle',
\})
