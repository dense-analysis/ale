" Author: Jansen Mitchell https://github.com/JansenMitchell
" Description: proselint for Fountain files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('fountain', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
