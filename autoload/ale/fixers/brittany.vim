" Author: eborden <evan@evan-borden.com>, ifyouseewendy <ifyouseewendy@gmail.com>, aspidiets <emarshall85@gmail.com>
" Description: Integration of brittany with ALE.

call ale#Set('haskell_brittany_executable', 'brittany')
call ale#Set('haskell_brittany_options', '--write-mode inplace')

function! ale#fixers#brittany#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'haskell_brittany_executable')
    let l:options = ale#Var(a:buffer, 'haskell_brittany_options')


    return {
    \   'command': ale#Escape(l:executable)
    \       . (!empty(l:options) ? ' ' . l:options : '--write-mode inplace')
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction

