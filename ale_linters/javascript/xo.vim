" Author: Daniel Lupu <lupu.daniel.f@gmail.com>
" Description: xo for JavaScript files

call ale#linter#Define('javascript', {
\   'name': 'xo',
\   'executable': {b -> ale#handlers#xo#GetExecutable(b)},
\   'command': {b -> ale#handlers#xo#GetLintCommand(b)},
\   'callback': 'ale#handlers#xo#HandleJSON',
\})
