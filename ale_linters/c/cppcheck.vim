" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for c files

call ale#Set('c_cppcheck_executable', 'cppcheck')
call ale#Set('c_cppcheck_options', '--enable=style')

function! ale_linters#c#cppcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_cppcheck_executable')
endfunction

function! ale_linters#c#cppcheck#GetCommand(buffer) abort
    return l:cd_command
    \   . ale#Escape(ale_linters#c#cppcheck#GetExecutable(a:buffer))
    \   . ' -q --language=c '
    \   . ale#Var(a:buffer, 'c_cppcheck_options')
    \   . ' %t'
endfunction

call ale#linter#Define('c', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable_callback': 'ale_linters#c#cppcheck#GetExecutable',
\   'command_callback': 'ale_linters#c#cppcheck#GetCommand',
\   'callback': 'ale#handlers#cppcheck#HandleCppCheckFormat',
\})
