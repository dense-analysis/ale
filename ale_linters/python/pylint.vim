" Author: keith <k@keith.so>
" Description: pylint for python files

let g:ale_python_pylint_executable =
\   get(g:, 'ale_python_pylint_executable', 'pylint')

let g:ale_python_pylint_options =
\   get(g:, 'ale_python_pylint_options', '')

function! ale_linters#python#pylint#GetExecutable(buffer) abort
    return g:ale_python_pylint_executable
endfunction

function! ale_linters#python#pylint#GetCommand(buffer) abort
    return ale_linters#python#pylint#GetExecutable(a:buffer)
    \   . ' ' . g:ale_python_pylint_options
    \   . ' --output-format text --msg-template="{path}:{line}:{column}: {msg_id} ({symbol}) {msg}" --reports n'
    \   . ' %t'
endfunction

call ale#linter#Define('python', {
\   'name': 'pylint',
\   'executable_callback': 'ale_linters#python#pylint#GetExecutable',
\   'command_callback': 'ale_linters#python#pylint#GetCommand',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
