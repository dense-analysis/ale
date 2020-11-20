" Author: pepo <josepgiraltdlacoste@gmail.com>, Josep Lluis Giralt D'Lacoste
" Description: Fixing erlang files with WhatsApp erlfmt `rebar3 fmt`.

call ale#Set('rebar3_executable', 'rebar3')
call ale#Set('erlfmt_options', '')

function! ale#fixers#erlfmt#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'rebar3_executable')
endfunction

function! ale#fixers#erlfmt#GetCommand(buffer) abort
    let l:executable = ale#Escape(ale#fixers#erlfmt#GetExecutable(a:buffer))
    let l:options = ale#Var(a:buffer, 'erlfmt_options')

    return l:executable . ' format'
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' %t'
endfunction

function! ale#fixers#erlfmt#Fix(buffer) abort
    return {
    \   'command': ale#fixers#erlfmt#GetCommand(a:buffer),
    \   'read_temporary_file': 1,
    \}
endfunction
