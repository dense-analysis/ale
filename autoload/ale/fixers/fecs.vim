" Author: harttle <yangjvn@126.com>
" Description: Apply fecs format to a file.

call ale#Set('html_fecs_executable', 'fecs')
call ale#Set('html_fecs_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#fecs#Fix(buffer) abort
    let l:executable = ale#handlers#fecs#GetExecutable(a:buffer)

    if !executable(l:executable)
        return 0
    endif

    let l:config_options = ' format --replace=true'

    return {
    \   'command': ale#Escape(l:executable) . l:config_options . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
