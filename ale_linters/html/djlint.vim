" Author: Vivian De Smedt <vds2212@gmail.com>
" Description: Adds support for djlint

call ale#Set('html_djlint_executable', 'djlint')
call ale#Set('html_djlint_options', '')

call ale#linter#Define('html', {
\   'name': 'djlint',
\   'executable': function('ale#handlers#djlint#GetExecutable'),
\   'command': function('ale#handlers#djlint#GetCommand'),
\   'callback': 'ale#handlers#djlint#Handle',
\})

" vim:ts=4:sw=4:et:
