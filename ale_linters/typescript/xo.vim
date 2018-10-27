" Author: Daniel Lupu <lupu.daniel.f@gmail.com>
" Description: xo for JavaScript files

call ale#linter#Define('typescript', {
\   'name': 'xo',
\   'executable_callback': 'ale#handlers#xo#GetExecutable',
\   'command_callback': 'ale#handlers#xo#GetCommand',
\   'callback': 'ale#handlers#eslint#Handle',
\})
