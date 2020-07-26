" Author: James Kim <jhlink@users.noreply.github.com>
" Description: Fix C/C++ files with astyle.

function! s:set_variables() abort
    for l:ft in ['c', 'cpp']
        call ale#Set(l:ft . '_astyle_executable', 'astyle')
    endfor
endfunction

call s:set_variables()

function! ale#fixers#astyle#Var(buffer, name) abort
    let l:ft = getbufvar(str2nr(a:buffer), '&filetype')
    let l:ft = l:ft =~# 'cpp' ? 'cpp' : 'c'

    return ale#Var(a:buffer, l:ft . '_astyle_' . a:name)
endfunction

function! ale#fixers#astyle#Fix(buffer) abort
    let l:executable = ale#fixers#astyle#Var(a:buffer, 'executable')
    let l:command = ' %t'

    return {
    \   'command': ale#Escape(l:executable) . l:command,
    \   'read_temporary_file': 1,
    \}
endfunction
