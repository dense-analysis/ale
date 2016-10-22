" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable': 'flake8',
\   'command': 'flake8 -',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
