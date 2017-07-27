" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: write-good for Markdown files

call ale#linter#Define('markdown', {
\   'name': 'write-good',
\   'executable': 'write-good',
\   'command': 'write-good --text="%t"',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
