" Author: epeery <eli.g.peery@gmail.com>"
" Description: Integration of ormolu with ALE.

call ale#Set('haskell_ormolu_executable', 'ormolu')

function! ale#fixers#ormolu#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'haskell_ormolu_executable')

    return ale#handlers#haskell_stack#EscapeExecutable(l:executable, 'ormolu')
endfunction

function! ale#fixers#ormolu#Fix(buffer) abort
    let l:executable = ale#fixers#ormolu#GetExecutable(a:buffer)

    return {
    \   'command': l:executable
    \       . ' --mode inplace'
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
