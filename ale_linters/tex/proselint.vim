" Author: poohzrn https://github.com/poohzrn
" Description: proselint for tex files

call ale#linter#Define('tex', {
\   'name': 'proselint',
\   'executable': 'proselint',
\   'command': 'proselint %t',
\   'callback': 'ale#handlers#HandleUnixFormatAsWarning',
\})
