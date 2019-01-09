" Author: TANIGUCHI Masaya <ta2gch@gmail.com>
" Description: textlint for AsciiDoc files

call ale#linter#Define('asciidoc', {
\   'name': 'textlint',
\   'executable_callback': 'ale#handlers#textlint#GetExecutable',
\   'command_callback': 'ale#handlers#textlint#GetCommand',
\   'callback': 'ale#handlers#textlint#HandleTextlintOutput',
\})
