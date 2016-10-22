" Author: KabbAmine - https://github.com/KabbAmine
" Description: Coffee for checking coffee files

call ale#linter#Define('coffee', {
\   'name': 'coffee',
\   'executable': 'coffee',
\   'command': 'coffee -cp -s',
\   'output_stream': 'stderr',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
