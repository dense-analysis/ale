" Author: w0rp <devw0rp@gmail.com>
" Description: eslint for JavaScript files

call ale#linter#Define('javascript', {
\   'name': 'eslint',
\   'executable_callback': 'ale#handlers#eslint#GetExecutable',
\   'command_callback': 'ale#handlers#eslint#GetCommand',
\   'callback': 'ale#handlers#eslint#Handle',
\   'output_stream': 'both',
\})

" Issue: #1246: eslint's internal errors are not shown.
" Fixer: Roney
" Description: Internal error output goes through `stderr`,
" so set 'output_stream' to 'both'.
" End: fix #1246
