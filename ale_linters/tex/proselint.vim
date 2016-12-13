" Author: poohzrn https://github.com/poohzrn
" Description: proselint for tex files

call ale#linter#Define('tex', {
\   'name': 'proselint',
\   'executable': 'proselint',
\   'command': g:ale#util#stdin_wrapper . ' .tex proselint',
\   'callback': 'ale#handlers#HandleUnixFormatAsWarning',
\})
