" Author: Johannes Wienke <languitar@semipol.de>
" Description: alex for HTML files

call ale#linter#Define('mail', {
\   'name': 'alex',
\   'executable': 'alex',
\   'command': 'alex %t -t',
\   'output_stream': 'stderr',
\   'callback': 'ale#handlers#alex#Handle',
\})
