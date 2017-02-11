" Author: w0rp - <devw0rp@gmail.com>
" Description: pug-lint for checking Pug/Jade files.

call ale#linter#Define('pug', {
\   'name': 'puglint',
\   'executable': 'pug-lint',
\   'output_stream': 'stderr',
\   'command': 'pug-lint -r inline %t',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
