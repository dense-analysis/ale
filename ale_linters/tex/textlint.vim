" Author: TANIGUCHI Masaya <ta2gch@gmail.com>
" Description: textlint for LaTeX files

call ale#linter#Define('tex', {
\   'name': 'textlint',
\   'executable_callback': 'ale#handlers#textlint#GetExecutable',
\   'command_callback': 'ale#handlers#textlint#GetCommand',
\   'callback': 'ale#handlers#textlint#HandleTextlintOutput',
\})
