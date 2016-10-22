" Author: neersighted <bjorn@neersighted.com>
" Description: go vet for Go files

call ale#linter#Define('go', {
\   'name': 'go vet',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command': g:ale#util#stdin_wrapper . ' .go go vet',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
