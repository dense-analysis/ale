" Author: chew-z https://github.com/chew-z
" Description: vale for text files

call ale#linter#Define('text', {
\   'name': 'vale',
\   'executable': 'vale',
\   'command': 'vale --output=line %t',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
