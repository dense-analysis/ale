" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

if exists('g:loaded_ale_linters_python_flake8')
    finish
endif

let g:loaded_ale_linters_python_flake8 = 1

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable': 'flake8',
\   'command': 'flake8 -',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
