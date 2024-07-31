" Author: Kohei YOSHIDA - https://github.com/yosida95
" Description: Helper functions for Erlang tools

call ale#Set('erlang_rebar_executable', 'rebar3')
call ale#Set('erlang_rebar_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#erlang#GetRebarExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'erlang_rebar', ['rebar3'])
endfunction
