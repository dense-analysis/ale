" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking CSS code with csslint.

if exists('g:loaded_ale_linters_css_csslint')
    finish
endif

let g:loaded_ale_linters_css_csslint = 1

call ale#linter#Define('css', {
\   'name': 'csslint',
\   'executable': 'csslint',
\   'command': g:ale#util#stdin_wrapper . ' .css csslint --format=compact',
\   'callback': 'ale#handlers#HandleCSSLintFormat',
\})
