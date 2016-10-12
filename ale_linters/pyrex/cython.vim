" Author: w0rp <devw0rp@gmail.com>
" Description: cython syntax checking for cython files.

call ale#linter#Define('pyrex', {
\   'name': 'cython',
\   'output_stream': 'stderr',
\   'executable': 'cython',
\   'command': g:ale#util#stdin_wrapper
\       . ' .pyx cython --warning-extra -o '
\       . g:ale#util#nul_file,
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
