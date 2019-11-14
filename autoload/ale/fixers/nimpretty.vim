" Author: Nhan <hi@imnhan.com>
" Description: Integration of nimpretty with ALE.

call ale#Set('nim_nimpretty_executable', 'nimpretty')
call ale#Set('nim_nimpretty_options', '--maxLineLen:80')
call ale#Set('nim_nimpretty_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#nimpretty#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'nim_nimpretty', ['nimpretty'])
endfunction

function! ale#fixers#nimpretty#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'nim_nimpretty_options')

    return {
    \   'command': ale#Escape(ale#fixers#nimpretty#GetExecutable(a:buffer))
    \       . ' %t'
    \       . (empty(l:options) ? '' : ' ' . l:options),
    \   'read_temporary_file': 1,
    \}
endfunction
