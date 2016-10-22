" Author: Chris Kyrouac - https://github.com/fijshion
" Description: jscs for JavaScript files

call ale#linter#Define('javascript', {
\   'name': 'jscs',
\   'executable': 'jscs',
\   'command': 'jscs -r unix -n -',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
