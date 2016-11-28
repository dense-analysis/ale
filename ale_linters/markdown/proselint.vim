" Author: poohzrn https://github.com/poohzrn
" Description: proselint for markdown files

call ale#linter#Define('markdown', {
\   'name': 'proselint',
\   'executable': 'proselint',
\   'command': g:ale#util#stdin_wrapper . ' .md proselint',
\   'callback': 'ale#handlers#HandleUnixFormatAsWarning',
\})
