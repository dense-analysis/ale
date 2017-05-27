" Author: KabbAmine <amine.kabb@gmail.com>, deathmaz <00maz1987@gmail.com>, diartyz <diartyz@gmail.com>
" Description: HTMLHint for checking html files

call ale#Set('html_htmlhint_options', '--format=unix')
call ale#Set('html_htmlhint_executable', 'htmlhint')
call ale#Set('html_htmlhint_use_global', 0)

function! ale_linters#html#htmlhint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'html_htmlhint', [
    \   'node_modules/.bin/htmlhint',
    \])
endfunction

function! ale_linters#html#htmlhint#GetCommand(buffer) abort
    return ale_linters#html#htmlhint#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'html_htmlhint_options')
    \   . ' %t'
endfunction

call ale#linter#Define('html', {
\   'name': 'htmlhint',
\   'executable_callback': 'ale_linters#html#htmlhint#GetExecutable',
\   'command_callback': 'ale_linters#html#htmlhint#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
