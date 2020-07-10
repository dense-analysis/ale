" Author: James Kim <jhlink@users.noreply.github.com>
" Description: Fix C files with astyle.

call ale#Set('c_astyle_executable', 'astyle')

function! ale#fixers#astyle#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'c_astyle_executable')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
