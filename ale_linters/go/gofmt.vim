" Author: neersighted <bjorn@neersighted.com>
" Description: gofmt for Go files

call ale#linter#Define('go', {
\   'name': 'gofmt',
\   'output_stream': 'stderr',
\   'executable': 'gofmt',
\   'command': g:ale#util#stdin_wrapper . ' .go gofmt -e',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
