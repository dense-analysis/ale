" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for cpp files

" Set this option to change the cppcheck options
let g:ale_cpp_cppcheck_options = get(g:, 'ale_cpp_cppcheck_options', '--enable=style')

function! ale_linters#cpp#cppcheck#GetCommand(buffer) abort
    return 'cppcheck -q --language=c++ '
    \   . ale#Var(a:buffer, 'cpp_cppcheck_options')
    \   . ' %t'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable': 'cppcheck',
\   'command_callback': 'ale_linters#cpp#cppcheck#GetCommand',
\   'callback': 'ale#handlers#HandleCppCheckFormat',
\})
