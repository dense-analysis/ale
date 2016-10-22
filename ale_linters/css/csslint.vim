" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking CSS code with csslint.

call ale#linter#Define('css', {
\   'name': 'csslint',
\   'executable': 'csslint',
\   'command': g:ale#util#stdin_wrapper . ' .css csslint --format=compact',
\   'callback': 'ale#handlers#HandleCSSLintFormat',
\})
