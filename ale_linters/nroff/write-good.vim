" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: write-good for nroff files

call ale#linter#Define('nroff', {
\   'name': 'write-good',
\   'executable': 'write-good',
\   'command': 'write-good --text="%t"',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
