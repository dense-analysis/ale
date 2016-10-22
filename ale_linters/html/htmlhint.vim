" Author: KabbAmine <amine.kabb@gmail.com>
" Description: HTMLHint for checking html files

call ale#linter#Define('html', {
\   'name': 'htmlhint',
\   'executable': 'htmlhint',
\   'command': 'htmlhint --format=unix stdin',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
