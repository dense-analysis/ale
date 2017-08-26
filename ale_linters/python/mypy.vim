" Author: Keith Smiley <k@keith.so>, w0rp <devw0rp@gmail.com>
" Description: mypy support for optional python typechecking

let g:ale_python_mypy_executable =
\   get(g:, 'ale_python_mypy_executable', 'mypy')
let g:ale_python_mypy_options = get(g:, 'ale_python_mypy_options', '')
let g:ale_python_mypy_use_global = get(g:, 'ale_python_mypy_use_global', 0)

function! ale_linters#python#mypy#GetExecutable(buffer) abort
    return ale#python#FindExecutable(a:buffer, 'python_mypy', ['mypy'])
endfunction

" The directory to change to before running mypy
function! s:GetDir(buffer) abort
    let l:project_root = ale#python#FindProjectRoot(a:buffer)

    return !empty(l:project_root)
    \   ? l:project_root
    \   : expand('#' . a:buffer . ':p:h')
endfunction

function! ale_linters#python#mypy#GetCommand(buffer) abort
    let l:dir = s:GetDir(a:buffer)
    let l:executable = ale_linters#python#mypy#GetExecutable(a:buffer)

    " We have to always switch to an explicit directory for a command so
    " we can know with certainty the base path for the 'filename' keys below.
    return ale#path#CdString(l:dir)
    \   . ale#Escape(l:executable)
    \   . ' --show-column-numbers '
    \   . ale#Var(a:buffer, 'python_mypy_options')
    \   . ' --shadow-file %s %t %s'
endfunction

function! ale_linters#python#mypy#Handle(buffer, lines) abort
    let l:dir = s:GetDir(a:buffer)
    " Look for lines like the following:
    "
    " file.py:4: error: No library stub file for module 'django.db'
    "
    " Lines like these should be ignored below:
    "
    " file.py:4: note: (Stub files are from https://github.com/python/typeshed)
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):?(\d+)?: (error|warning): (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': l:match[4] is# 'error' ? 'E' : 'W',
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
