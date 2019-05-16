" Author: Autoine Gagne - https://github.com/AntoineGagne
" Description: Define a checker that runs dialyzer on Erlang files.

function! ale_linters#erlang#dialyzer#FindPlt() abort
    let l:plt_file = split(globpath('_build', '**/*_plt'), '\n')

    if !empty(l:plt_file)
        return l:plt_file[0]
    endif

    if !empty($REBAR_PLT_DIR)
        return expand('$REBAR_PLT_DIR/dialyzer/plt')
    endif

    return expand('$HOME/.dialyzer_plt')
endfunction

function! ale_linters#erlang#dialyzer#GetPlt(buffer) abort
    return ale#Var(a:buffer, 'erlang_plt_file')
endfunction

function! ale_linters#erlang#dialyzer#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'erlang_dialyzer_executable')
endfunction

function! ale_linters#erlang#dialyzer#GetCommand(buffer) abort
    let l:command = fnameescape(ale_linters#erlang#dialyzer#GetExecutable(a:buffer))
    \   . ' -n'
    \   . ' --plt ' . fnameescape(ale_linters#erlang#dialyzer#GetPlt(a:buffer))
    \   . ' -Wunmatched_returns'
    \   . ' -Werror_handling'
    \   . ' -Wrace_conditions'
    \   . ' -Wunderspecs'
    \   . ' %s'

    return l:command
endfunction

function! ale_linters#erlang#dialyzer#Handle(buffer, lines) abort
    " Match patterns like the following:
    "
    " erl_tidy_prv_fmt.erl:3: Callback info about the provider behaviour is not available
    let l:pattern = '^\S\+:\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) != 0
            let l:code = l:match[2]

            call add(l:output, {
            \   'lnum': l:match[1] + 0,
            \   'lcol': 0,
            \   'text': l:code,
            \   'type': 'W'
            \})
        endif
    endfor

    return l:output
endfunction

let g:ale_erlang_dialyzer_executable =
\   get(g:, 'ale_erlang_dialyzer_executable', 'dialyzer')
let g:ale_erlang_plt_file =
\   get(g:, 'ale_erlang_plt_file', ale_linters#erlang#dialyzer#FindPlt())

call ale#linter#Define('erlang', {
\   'name': 'dialyzer',
\   'executable': function('ale_linters#erlang#dialyzer#GetExecutable'),
\   'command': function('ale_linters#erlang#dialyzer#GetCommand'),
\   'callback': function('ale_linters#erlang#dialyzer#Handle')
\})
