" Author: Pat Brisbin <pbrisbin@gmail.com>
" Description: Integration of dhall-format with ALE.

call ale#Set('dhall_format_executable', 'dhall')
call ale#Set('dhall_format_ascii', 0)

function! ale#fixers#dhall#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'dhall_format_executable')

    " Dhall is written in Haskell and commonly installed with Stack
    return ale#handlers#haskell_stack#EscapeExecutable(l:executable, 'dhall')
endfunction

function! ale#fixers#dhall#Fix(buffer) abort
    let l:executable = ale#fixers#dhall#GetExecutable(a:buffer)

    let l:command = l:executable
    \       . ' format'
    \       . ' --inplace'
    \       . ' %t'

    if ale#Var(a:buffer, 'dhall_format_ascii')
        let l:command .= ' --ascii'
    endif

    return {
    \   'command': l:command,
    \   'read_temporary_file': 1,
    \}
endfunction
