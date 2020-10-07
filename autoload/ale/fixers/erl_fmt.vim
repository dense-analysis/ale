" Author: pepo <josepgiraltdlacoste@gmail.com>, Josep Lluis Giralt D'Lacoste
" Description: Fixing erlang files with WhatsApp erlfmt `rebar3 fmt`.

call ale#Set('rebar3_executable', 'rebar3')
call ale#Set('erl_fmt_options', '')

function! ale#fixers#erl_fmt#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'rebar3_executable')
endfunction

function! ale#fixers#erl_fmt#GetCommand(buffer) abort
    let l:executable = ale#Escape(ale#fixers#erl_fmt#GetExecutable(a:buffer))
    let l:options = ale#Var(a:buffer, 'erl_fmt_options')

    return l:executable . ' format'
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' %t'
endfunction

function! ale#fixers#erl_fmt#Fix(buffer) abort
    return {
    \   'command': ale#fixers#erl_fmt#GetCommand(a:buffer),
    \   'read_temporary_file': 1,
    \}
endfunction
