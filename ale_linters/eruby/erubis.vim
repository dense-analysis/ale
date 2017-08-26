" Author: Jake Zimmerman <jake@zimmerman.io>
" Description: eruby checker using `erubis`, instead of `erb`

call ale#linter#Define('eruby', {
\   'name': 'erubis',
\   'executable': 'erubis',
\   'output_stream': 'stderr',
\   'command': 'erubis -x %t | ruby -c',
\   'callback': 'ale#handlers#ruby#HandleSyntaxErrors',
\})

