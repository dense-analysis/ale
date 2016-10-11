" Author: neersighted <bjorn@neersighted.com>
" Description: go vet for Go files

if exists('g:loaded_ale_linters_go_govet')
    finish
endif

let g:loaded_ale_linters_go_govet = 1

call ale#linter#Define('go', {
\   'name': 'go vet',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command': g:ale#util#stdin_wrapper . ' .go go vet',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})

