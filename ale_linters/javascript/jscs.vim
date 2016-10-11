" Author: Chris Kyrouac - https://github.com/fijshion
" Description: jscs for JavaScript files

if exists('g:loaded_ale_linters_javascript_jscs')
    finish
endif

let g:loaded_ale_linters_javascript_jscs = 1

call ale#linter#Define('javascript', {
\   'name': 'jscs',
\   'executable': 'jscs',
\   'command': 'jscs -r unix -n -',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
