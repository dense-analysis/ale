" Author: soywod <clement.douin@gmail.com>
" Description: Integration of Elm with ALE.

call ale#Set('elm_format_executable', 'elm-format')
call ale#Set('elm_format_use_global', 1)
call ale#Set('elm_format_options', '--yes')

function! ale#fixers#format#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'elm_format', [
    \   'node_modules/.bin/elm-format',
    \   'node_modules/elm-format/bin/elm-format',
    \   'node_modules/elm-format/index.js',
    \])
endfunction

function! ale#fixers#format#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'elm_format_options')

    return {
    \   'command': ale#Escape(ale#fixers#format#GetExecutable(a:buffer))
    \       . ' %t'
    \       . (empty(l:options) ? '' : ' ' . l:options),
    \   'read_temporary_file': 1,
    \}
endfunction
