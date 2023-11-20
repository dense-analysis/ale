call ale#Set('haskell_ormolu_executable', 'ormolu')
call ale#Set('haskell_ormolu_options', '')

function! ale#fixers#ormolu#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'haskell_ormolu_executable')

    return ale#handlers#haskell_stack#EscapeExecutable(l:executable, 'ormolu')
endfunction

function! ale#fixers#ormolu#Fix(buffer) abort
    let l:executable = ale#fixers#ormolu#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'haskell_ormolu_options')

    return {
    \   'command': l:executable
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \       . ' --stdin-input-file '
    \       . ale#Escape(@%),
    \}
endfunction
