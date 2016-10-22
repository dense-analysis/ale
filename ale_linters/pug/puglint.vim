" Author: w0rp - <devw0rp@gmail.com>
" Description: pug-lint for checking Pug/Jade files.

call ale#linter#Define('pug', {
\   'name': 'puglint',
\   'executable': 'pug-lint',
\   'output_stream': 'stderr',
\   'command': g:ale#util#stdin_wrapper . ' .pug pug-lint -r inline',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
