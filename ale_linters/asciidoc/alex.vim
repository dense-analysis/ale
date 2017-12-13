" Author: Johannes Wienke <languitar@semipol.de>
" Description: alex for asciidoc files

call ale#linter#Define('asciidoc', {
\   'name': 'alex',
\   'executable': 'alex',
\   'command': 'alex %t -t',
\   'output_stream': 'stderr',
\   'callback': 'ale#handlers#alex#Handle',
\})
