" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: write-good for Texinfo files

call ale#linter#Define('texinfo', {
\   'name': 'write-good',
\   'executable': 'write-good',
\   'command': 'write-good %t',
\   'callback': 'ale#handlers#writegood#HandleAsWarning',
\})
