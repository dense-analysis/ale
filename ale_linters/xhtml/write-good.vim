" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: write-good for XHTML files

call ale#linter#Define('xhtml', {
\   'name': 'write-good',
\   'executable': 'write-good',
\   'command': 'write-good %t',
\   'callback': 'ale#handlers#writegood#HandleAsWarning',
\})
