call ale#Set('haskell_hlint_executable', 'hlint')
call ale#Set('haskell_hlint_options', get(g:, 'hlint_options', ''))

function! ale#handlers#hlint#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'haskell_hlint_executable')
    return ale#handlers#haskell_stack#EscapeExecutable(l:executable, 'hlint')
endfunction

function! ale#handlers#hlint#GetLintCommand(buffer) abort
    let l:hlintopts = '--color=never --json'

    return ale#handlers#hlint#GetExecutable(a:buffer)
    \      . ' ' . ale#Var(a:buffer, 'haskell_hlint_options')
    \      . ' ' . l:hlintopts . ' -'
endfunction
