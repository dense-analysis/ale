" Author: poohzrn https://github.com/poohzrn
" Description: proselint for TeX files

call ale#Set('proselint_executable', 'proselint')

call ale#linter#Define('tex', {
\   'name': 'proselint',
\   'executable': function('ale#proselint#GetExecutable'),
\   'command': function('ale#proselint#GetCommandWithVersionCheck'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
