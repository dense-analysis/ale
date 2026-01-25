" Author: Daniel M. Capella https://github.com/polyzen
" Description: proselint for nroff files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('nroff', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
