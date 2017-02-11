" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for cpp files

" Set this option to change the cppcheck options
let g:ale_cpp_cppcheck_options = get(g:, 'ale_cpp_cppcheck_options', '--enable=style')

call ale#linter#Define('cpp', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable': 'cppcheck',
\   'command': 'cppcheck -q --language=c++ '
\       . g:ale_cpp_cppcheck_options
\       . ' %t',
\   'callback': 'ale#handlers#HandleCppCheckFormat',
\})
