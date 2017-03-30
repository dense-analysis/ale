" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl syntax

let g:ale_perl_perl_executable =
\   get(g:, 'ale_perl_perl_executable', 'perl')

let g:ale_perl_perl_options =
\   get(g:, 'ale_perl_perl_options', '-X -c -Mwarnings -Ilib')

function! ale_linters#perl#perl#GetExecutable(buffer) abort
    return g:ale_perl_perl_executable
endfunction

function! ale_linters#perl#perl#GetCommand(buffer) abort
    return ale_linters#perl#perl#GetExecutable(a:buffer)
    \   . ' ' . g:ale_perl_perl_options
    \   . ' %t'
endfunction

function! ale_linters#perl#perl#Handle(buffer, lines) abort
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[3]
        let l:text = l:match[1]
        let l:type = 'E'

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'text': l:text,
        \   'type': l:type,
        \})
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
