" Author: w0rp <devw0rp@gmail.com>
" Description: eslint for JavaScript files

call ale#linter#Define('javascript', {
\   'name': 'eslint',
\   'executable_callback': 'ale#handlers#eslint#GetExecutable',
\   'command_callback': 'ale#handlers#eslint#GetCommand',
\   'callback': 'ale#handlers#eslint#Handle',
\   'output_stream': 'both',
\})
