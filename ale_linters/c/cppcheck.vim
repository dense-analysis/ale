" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for c files

" Set this option to change the cppcheck options
let g:ale_c_cppcheck_options = get(g:, 'ale_c_cppcheck_options', '--enable=style')

function! ale_linters#c#cppcheck#GetCommand(buffer) abort
    return 'cppcheck -q --language=c '
    \   . ale#Var(a:buffer, 'c_cppcheck_options')
    \   . ' %t'
endfunction

call ale#linter#Define('c', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable': 'cppcheck',
\   'command_callback': 'ale_linters#c#cppcheck#GetCommand',
\   'callback': 'ale#handlers#HandleCppCheckFormat',
\})
