" Author: Doron Behar <doron.behar@gmail.com>
" Description: textlint, a proofreading tool (https://textlint.github.io/)

call ale#linter#Define('html', {
\   'name': 'textlint',
\   'executable_callback': 'ale#handlers#textlint#GetExecutable',
\   'command_callback': 'ale#handlers#textlint#GetCommand',
\   'callback': 'ale#handlers#textlint#HandleTextlintOutput',
\})
