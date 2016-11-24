" Author: dzhou121 <dzhou121@gmail.com>
" Description: go build for Go files

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command': g:ale#util#stdin_wrapper . ' .go go build',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
