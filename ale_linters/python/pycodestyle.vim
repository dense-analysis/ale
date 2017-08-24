" Author: Michael Thiesen <micthiesen@gmail.com>
" Description: pycodestyle linting for python files

let g:ale_python_pycodestyle_executable =
\   get(g:, 'ale_python_pycodestyle_executable', 'pycodestyle')
let g:ale_python_pycodestyle_options =
\   get(g:, 'ale_python_pycodestyle_options', '')

function! ale_linters#python#pycodestyle#GetExecutable(buffer) abort
    return ale#python#FindExecutable(a:buffer, 'python_pycodestyle', ['pycodestyle'])
endfunction

function! ale_linters#python#pycodestyle#GetCommand(buffer) abort
    return ale#Escape(ale_linters#python#pycodestyle#GetExecutable(a:buffer))
    \   . ale#Var(a:buffer, 'python_pycodestyle_options')
endfunction

call ale#linter#Define('python', {
\   'name': 'pycodestyle',
\   'executable_callback': 'ale_linters#python#pycodestyle#GetExecutable',
\   'command_callback': 'ale_linters#python#pycodestyle#GetCommand',
\   'callback': 'ale_linters#python#pycodestyle#Handle',
\})
