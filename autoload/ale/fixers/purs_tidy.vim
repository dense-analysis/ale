" Author: toastal <toastal@posteo.net>
" Description: Integration of purty with ALE.

call ale#Set('purescript_tidy_executable', 'purs-tidy')

function! ale#fixers#purty#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'purescript_tidy_executable')

    return ale#Escape(l:executable)
endfunction

function! ale#fixers#purty#Fix(buffer) abort
    let l:executable = ale#fixers#purty#GetExecutable(a:buffer)

    return {
    \   'command': l:executable
    \       . ' format-in-place'
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction

