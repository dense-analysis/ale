" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

let g:ale_python_flake8_executable =
\   get(g:, 'ale_python_flake8_executable', 'flake8')

let g:ale_python_flake8_args =
\   get(g:, 'ale_python_flake8_args', '')

function! ale_linters#python#flake8#GetExecutable(buffer) abort
    return g:ale_python_flake8_executable
endfunction

function! ale_linters#python#flake8#GetCommand(buffer) abort
    return ale_linters#python#flake8#GetExecutable(a:buffer)
    \   . ' ' . g:ale_python_flake8_args . '--stdin-display-name %s -'
endfunction

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable_callback': 'ale_linters#python#flake8#GetExecutable',
\   'command_callback': 'ale_linters#python#flake8#GetCommand',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
