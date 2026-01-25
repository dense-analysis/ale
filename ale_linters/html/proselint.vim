" Author: Daniel M. Capella https://github.com/polyzen
" Description: proselint for HTML files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('html', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
