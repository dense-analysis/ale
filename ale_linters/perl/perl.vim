" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl syntax

let g:ale_perl_perl_executable =
\   get(g:, 'ale_perl_perl_executable', 'perl')

let g:ale_perl_perl_options =
\   get(g:, 'ale_perl_perl_options', '-c -Mwarnings -Ilib')

function! ale_linters#perl#perl#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'perl_perl_executable')
endfunction

function! ale_linters#perl#perl#GetCommand(buffer) abort
    return ale_linters#perl#perl#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'perl_perl_options')
    \   . ' %t'
endfunction

function! ale_linters#perl#perl#Handle(buffer, lines) abort
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []
    let l:basename = expand('#' . a:buffer . ':t')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[3]
        let l:text = l:match[1]
        let l:type = 'E'

        if l:match[2][-len(l:basename):] ==# l:basename
        \&& l:text !=# 'BEGIN failed--compilation aborted'
            call add(l:output, {
            \   'lnum': l:line,
            \   'text': l:text,
            \   'type': l:type,
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('perl', {
\   'name': 'perl',
\   'executable_callback': 'ale_linters#perl#perl#GetExecutable',
\   'output_stream': 'both',
\   'command_callback': 'ale_linters#perl#perl#GetCommand',
\   'callback': 'ale_linters#perl#perl#Handle',
\})
