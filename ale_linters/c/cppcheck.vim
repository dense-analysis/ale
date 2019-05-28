" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for c files

call ale#Set('c_cppcheck_executable', 'cppcheck')
call ale#Set('c_cppcheck_options', '--enable=style')

function! ale_linters#c#cppcheck#GetCommand(buffer) abort

    let l:cd_command = ale_linters#cpp#cppcheck#GetCdCommand(a:buffer)
    let l:compile_commands_option = ale#handlers#cppcheck#GetCompileCommandsOptions(a:buffer)
    let l:buffer_path_include = ale#handlers#cppcheck#GetBufferPathIncludeOption(a:buffer)

    return l:cd_command
    \   . '%e -q --language=c '
    \   . l:compile_commands_option
    \   . ale#Var(a:buffer, 'c_cppcheck_options')
    \   . l:buffer_path_include
    \   . ' %t'
endfunction

call ale#linter#Define('c', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable': {b -> ale#Var(b, 'c_cppcheck_executable')},
\   'command': function('ale_linters#c#cppcheck#GetCommand'),
\   'callback': 'ale#handlers#cppcheck#HandleCppCheckFormat',
\})
