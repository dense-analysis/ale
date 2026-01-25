" Author: chew-z https://github.com/chew-z
" Description: vale for text files

call ale#Set('vale_executable', 'vale')
call ale#Set('vale_options', '')

function! ale_linters#text#vale#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'vale_executable')

    let l:options = ale#Var(a:buffer, 'vale_options')

    return ale#Escape(l:executable)
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' --output=JSON %t'
endfunction

call ale#linter#Define('text', {
\   'name': 'vale',
\   'executable': 'vale',
\   'command': function('ale_linters#text#vale#GetCommand'),
\   'callback': 'ale#handlers#vale#Handle',
\})
