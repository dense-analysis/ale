" Author: Keith Smiley <k@keith.so>
" Description: mypy support for optional python typechecking

let g:ale_python_mypy_args = get(g:, 'ale_python_mypy_options', '')

function! g:ale_linters#python#mypy#GetCommand(buffer) abort
    return g:ale#util#stdin_wrapper
    \   . ' .py mypy --show-column-numbers '
    \   . g:ale_python_mypy_options
endfunction

call g:ale#linter#Define('python', {
\   'name': 'mypy',
\   'executable': 'mypy',
\   'command_callback': 'ale_linters#python#mypy#GetCommand',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
