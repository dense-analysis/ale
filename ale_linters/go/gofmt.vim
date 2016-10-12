" Author: neersighted <bjorn@neersighted.com>
" Description: gofmt for Go files

if exists('g:loaded_ale_linters_go_gofmt')
    finish
endif

let g:loaded_ale_linters_go_gofmt = 1

call ale#linter#Define('go', {
\   'name': 'gofmt',
\   'output_stream': 'stderr',
\   'executable': 'gofmt',
\   'command': g:ale#util#stdin_wrapper . ' .go gofmt -e',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})

