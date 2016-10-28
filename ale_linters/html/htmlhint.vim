" Author: KabbAmine <amine.kabb@gmail.com>, deathmaz <00maz1987@gmail.com>
" Description: HTMLHint for checking html files

" CLI options
let g:ale_html_htmlhint_options = get(g:, 'ale_html_htmlhint_options', '--format=unix')

call ale#linter#Define('html', {
\   'name': 'htmlhint',
\   'executable': 'htmlhint',
\   'command': 'htmlhint ' . g:ale_html_htmlhint_options . ' stdin',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
