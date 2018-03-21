" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for cpp files

call ale#Set('cpp_cppcheck_executable', 'cppcheck')
call ale#Set('cpp_cppcheck_options', '--enable=style')

function! ale_linters#cpp#cppcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_cppcheck_executable')
endfunction

function! ale_linters#cpp#cppcheck#GetCommand(buffer) abort
    return ale#Escape(ale_linters#cpp#cppcheck#GetExecutable(a:buffer))
    \   . ' -q --language=c++ '
    \   . ale#Var(a:buffer, 'cpp_cppcheck_options')
    \   . ' %t'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable_callback': 'ale_linters#cpp#cppcheck#GetExecutable',
\   'command_callback': 'ale_linters#cpp#cppcheck#GetCommand',
\   'callback': 'ale#handlers#cppcheck#HandleCppCheckFormat',
\})
