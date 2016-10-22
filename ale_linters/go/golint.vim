" Author: neersighted <bjorn@neersighted.com>
" Description: golint for Go files

call ale#linter#Define('go', {
\   'name': 'golint',
\   'executable': 'golint',
\   'command': g:ale#util#stdin_wrapper . ' .go golint',
\   'callback': 'ale#handlers#HandleUnixFormatAsWarning',
\})
