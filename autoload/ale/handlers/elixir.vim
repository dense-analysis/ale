call ale#Set('elixir_executable', '')

function! ale#handlers#elixir#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'elixir_executable')
endfunction
