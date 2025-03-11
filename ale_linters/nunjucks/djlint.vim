" Author: Adrian Vollmer <computerfluesterer@protonmail.com>
" Description: djlint for Django HTML template files

call ale#Set('html_djlint_executable', 'djlint')
call ale#Set('html_djlint_options', '')

call ale#linter#Define('nunjucks', {
\   'name': 'djlint',
\   'executable': function('ale#handlers#djlint#GetExecutable'),
\   'command': function('ale#handlers#djlint#GetCommand'),
\   'callback': 'ale#handlers#djlint#Handle',
\})
