" Author: Daniel M. Capella https://github.com/polyzen
" Description: proselint for Pod files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('pod', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
