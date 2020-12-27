" Author: Mohammed Chelouti - https://github.com/motato1
" Description: Handler functions for Deno.

call ale#Set('deno_executable', 'deno')
call ale#Set('deno_unstable', 0)

function! ale#handlers#deno#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'deno_executable')
endfunction
