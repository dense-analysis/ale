" Author: poohzrn https://github.com/poohzrn
" Description: proselint for markdown files

call ale#linter#Define('markdown', {
\   'name': 'proselint',
\   'executable': 'proselint',
\   'command': 'proselint %t',
\   'callback': 'ale#handlers#HandleUnixFormatAsWarning',
\})
