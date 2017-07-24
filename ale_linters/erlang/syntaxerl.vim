" Author: Dmitri Vereshchagin <dmitri.vereshchagin@gmail.com>
" Description: SyntaxErl linter for Erlang files

call ale#Set('erlang_syntaxerl_executable', 'syntaxerl')


function! ale_linters#erlang#syntaxerl#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'erlang_syntaxerl_executable')
endfunction


function! ale_linters#erlang#syntaxerl#GetCommand(buffer) abort
    return ale_linters#erlang#syntaxerl#GetExecutable(a:buffer) . ' %t'
endfunction


function! ale_linters#erlang#syntaxerl#Handle(buffer, lines) abort
    let l:pattern = '\v\C:(\d+):( warning:)? (.+)'
    let l:loclist = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:loclist, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[3],
        \   'type': empty(l:match[2]) ? 'E' : 'W',
        \})
    endfor

    return l:loclist
endfunction


call ale#linter#Define('erlang', {
\   'name': 'syntaxerl',
\   'executable_callback': 'ale_linters#erlang#syntaxerl#GetExecutable',
\   'command_callback': 'ale_linters#erlang#syntaxerl#GetCommand',
\   'callback': 'ale_linters#erlang#syntaxerl#Handle',
\})
