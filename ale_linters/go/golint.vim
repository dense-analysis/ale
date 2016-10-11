" Author: neersighted <bjorn@neersighted.com>
" Description: golint for Go files

if exists('g:loaded_ale_linters_go_golint')
    finish
endif

let g:loaded_ale_linters_go_golint = 1

call ale#linter#Define('go', {
\   'name': 'golint',
\   'executable': 'golint',
\   'command': g:ale#util#stdin_wrapper . ' .go golint',
\   'callback': 'ale#handlers#HandleUnixFormatAsWarning',
\})
