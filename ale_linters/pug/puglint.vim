" Author: w0rp - <devw0rp@gmail.com>
" Description: pug-lint for checking Pug/Jade files.

if exists('g:loaded_ale_linters_pug_puglint')
    finish
endif

let g:loaded_ale_linters_pug_puglint = 1

call ale#linter#Define('pug', {
\   'name': 'puglint',
\   'executable': 'pug-lint',
\   'output_stream': 'stderr',
\   'command': g:ale#util#stdin_wrapper . ' .pug pug-lint -r inline',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
