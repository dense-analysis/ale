" Author: Chris Weyl <cweyl@alumni.drew.edu>

" This is a collection of utility functions largely aimed at consolidating
" some common functionality in one place.

function! ale#linter#util#SetStandardVars(linter, executable) abort
    call ale#Set(a:linter.'_executable', a:executable)
    call ale#Set(a:linter.'_options', '')
    return
endfunction

function! ale#linter#util#GetBufExec(buffer, linter) abort
    return ale#Var(a:buffer, a:linter.'_executable')
endfunction

function! ale#linter#util#GetCommand(buffer, linter) abort
    let l:command = ale#Escape(ale#Var(a:buffer, a:linter.'_executable')) . ' '
    \  . ale#Var(a:buffer, a:linter.'_options') . ' %t'
    return l:command
endfunction
