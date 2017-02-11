" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for c files

" Set this option to change the cppcheck options
let g:ale_c_cppcheck_options = get(g:, 'ale_c_cppcheck_options', '--enable=style')

call ale#linter#Define('c', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable': 'cppcheck',
\   'command': 'cppcheck -q --language=c '
\       . g:ale_c_cppcheck_options
\       . ' %t',
\   'callback': 'ale#handlers#HandleCppCheckFormat',
\})
