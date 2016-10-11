" Author: KabbAmine <amine.kabb@gmail.com>
" Description: HTMLHint for checking html files

if exists('g:loaded_ale_linters_html_htmlhint')
    finish
endif

let g:loaded_ale_linters_html_htmlhint = 1

call ale#linter#Define('html', {
\   'name': 'htmlhint',
\   'executable': 'htmlhint',
\   'command': 'htmlhint --format=unix stdin',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
