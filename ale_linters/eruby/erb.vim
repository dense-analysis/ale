" Author: Matthias Guenther - https://wikimatze.de
" Description: ERB from the Ruby standard library, for eruby/erb files

call ale#linter#Define('eruby', {
\   'name': 'erb',
\   'executable': 'erb',
\    'output_stream': 'stderr',
\   'command': 'erb -P -x %t | ruby -c',
\   'callback': 'ale#handlers#ruby#HandleSyntaxErrors',
\})

