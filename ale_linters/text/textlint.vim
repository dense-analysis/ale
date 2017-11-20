" Author: Yasuhiro Kiyota <yasuhiroki.duck@gmail.com>
" Description: textlint for text files

call ale#linter#Define('text', {
\   'name': 'textlint',
\   'executable_callback': 'ale#handlers#textlint#GetExecutable',
\   'command_callback': 'ale#handlers#textlint#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
