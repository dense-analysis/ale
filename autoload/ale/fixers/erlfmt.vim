" Author: AntoineGagne - https://github.com/AntoineGagne
" Description: Integration of erlfmt with ALE.

call ale#Set('erlang_erlfmt_executable', 'erlfmt')
call ale#Set('erlang_erlfmt_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('erlang_erlfmt_options', '')
call ale#Set('erlang_erlfmt_use_rebar', 0)

call ale#Set('erlang_rebar_executable', 'rebar3')
call ale#Set('erlang_rebar_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#erlfmt#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'erlang_erlfmt', ['erlfmt'])
endfunction

function! ale#fixers#erlfmt#GetRebarExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'erlang_rebar', ['rebar3'])
endfunction

function! ale#fixers#erlfmt#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'erlang_erlfmt_options')
    let l:use_rebar = ale#Var(a:buffer, 'erlang_erlfmt_use_rebar')

    if l:use_rebar
        let l:executable = ale#fixers#erlfmt#GetRebarExecutable(a:buffer)
        let l:command = [ale#Escape(l:executable), 'fmt']
    else
        let l:executable = ale#fixers#erlfmt#GetExecutable(a:buffer)
        let l:command = [ale#Escape(l:executable)]
    endif

    if !empty(l:options)
        call add(l:command, l:options)
    endif

    let l:read_temporary_file = 0

    if l:use_rebar
        " As rebar3 emits error messages to STDOUT rather than STDERR, read the
        " temporary file to prevent the buffer from being overridden by error
        " messages.
        call extend(l:command, ['--write', '%t'])
        let l:read_temporary_file = 1
    else
        call add(l:command, '-')
    endif

    return {
    \   'command': join(l:command, ' '),
    \   'read_temporary_file': l:read_temporary_file,
    \}
endfunction
