" Author: Brandon Roehl - https://github.com/BrandonRoehl
" Description: Ruby MRI for Ruby files

call ale#linter#Define('ruby', {
\   'name': 'ruby',
\   'executable': 'ruby',
\   'output_stream': 'stderr',
\   'command': 'ruby -w -c -T1 %t',
\   'callback': 'ale#handlers#ruby#HandleSyntaxErrors',
\})
