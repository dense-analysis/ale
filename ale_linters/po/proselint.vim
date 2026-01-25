" Author: Cian Butler https://github.com/butlerx
" Description: proselint for PO files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('po', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
