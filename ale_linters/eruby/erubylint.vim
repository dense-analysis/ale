" Author: Matthias Guenther - https://wikimatze.de
" Description: erb-lint for eruby/erb files

call ale#linter#Define('eruby', {
\   'name': 'erubylint',
\   'executable': 'erb',
\    'output_stream': 'stderr',
\   'command': 'erb -P -x %t | ruby -c',
\   'callback': 'ale#handlers#ruby#HandleSyntaxErrors',
\})

