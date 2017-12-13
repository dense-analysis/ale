" Author: Johannes Wienke <languitar@semipol.de>
" Description: alex for XHTML files

call ale#linter#Define('xhtml', {
\   'name': 'alex',
\   'executable': 'alex',
\   'command': 'alex %t -t',
\   'output_stream': 'stderr',
\   'callback': 'ale#handlers#alex#Handle',
\})
