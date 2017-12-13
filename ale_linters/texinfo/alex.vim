" Author: Johannes Wienke <languitar@semipol.de>
" Description: alex for texinfo files

call ale#linter#Define('texinfo', {
\   'name': 'alex',
\   'executable': 'alex',
\   'command': 'alex %t -t',
\   'output_stream': 'stderr',
\   'callback': 'ale#handlers#alex#Handle',
\})
