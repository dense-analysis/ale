" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: write-good for vim Help files

call ale#linter#Define('help', {
\   'name': 'write-good',
\   'executable': 'write-good',
\   'command': 'write-good %t',
\   'callback': 'ale#handlers#writegood#HandleAsWarning',
\})
