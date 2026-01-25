" Author: Daniel M. Capella https://github.com/polyzen
" Description: proselint for mail files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('mail', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
