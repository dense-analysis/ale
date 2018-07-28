" File: ghdl.vim
" Author: John Gentile <johncgentile17@gmail.com>
" Description: This file adds support for ghdl for VHDL

call ale#Set('vhdl_ghdl_options', '')

function! ale_linters#vhdl#ghdl#GetCommand(buffer) abort
    return 'ghdl -s --std=08 '
    \   . ale#Var(a:buffer, 'vhdl_ghdl_options')
    \   . ' %t'
endfunction

function! ale_linters#vhdl#ghdl#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " dff_en.vhd:41:5:error: 'begin' is expected instead of 'if'
    let l:pattern = '^\s*\u\=:\=[^:]\+:\(\d\+\):\(\d\+\): \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[1] + 0
        let l:col = l:match[2] + 0
        " GHDL syntax output does not parse warning|error
        let l:type = 'E'
        let l:text = l:match[3]

        call add(l:output, {
        \   'lnum': l:line,
        \   'text': l:text,
        \   'col' : l:col,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('vhdl', {
\   'name': 'ghdl',
\   'output_stream': 'stderr',
\   'executable': 'ghdl',
\   'command_callback': 'ale_linters#vhdl#ghdl#GetCommand',
\   'callback': 'ale_linters#vhdl#ghdl#Handle',
\})
