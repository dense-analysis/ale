" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: write-good for AsciiDoc files

call ale#linter#Define('asciidoc', {
\   'name': 'write-good',
\   'executable': 'write-good',
\   'command': 'write-good %t',
\   'callback': 'ale#handlers#writegood#HandleAsWarning',
\})
