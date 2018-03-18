" Author: Yasuhiro Kiyota <yasuhiroki.duck@gmail.com>
" Description: Integration of textlint with ALE.

call ale#Set('textlint_executable', 'textlint')
call ale#Set('textlint_use_global', 0)
call ale#Set('textlint_options', '')

function! ale#handlers#textlint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'textlint', [
    \   'node_modules/.bin/textlint',
    \   'node_modules/textlint/bin/textlint.js',
    \])
endfunction

function! ale#handlers#textlint#GetCommand(buffer) abort
    let l:executable = ale#handlers#textlint#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'textlint_options')

    return ale#node#Executable(a:buffer, l:executable)
    \   . ' --format unix'
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' %t'
endfunction
