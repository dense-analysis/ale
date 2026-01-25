" Author: poohzrn https://github.com/poohzrn
" Description: proselint for text files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('text', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
