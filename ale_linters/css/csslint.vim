" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking CSS code with csslint.

call ale#linter#Define('css', {
\   'name': 'csslint',
\   'executable': 'csslint',
\   'command': 'csslint --format=compact %t',
\   'callback': 'ale#handlers#HandleCSSLintFormat',
\})
