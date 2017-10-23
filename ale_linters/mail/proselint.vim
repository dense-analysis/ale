" Author: Daniel M. Capella https://github.com/polyzen
" Description: proselint for mail files

call ale#linter#Define('mail', {
\   'name': 'mail',
\   'executable': 'proselint',
\   'command': 'proselint %t',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
