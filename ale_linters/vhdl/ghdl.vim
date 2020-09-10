" Author: John Gentile <johncgentile17@gmail.com>
" Description: Adds support for `ghdl` VHDL compiler/checker

call ale#Set('vhdl_ghdl_executable', 'ghdl')
" Compile w/VHDL-2008 support
call ale#Set('vhdl_ghdl_options', '--std=08')

function! ale_linters#vhdl#ghdl#GetCommand(buffer) abort
    return '%e -s ' . ale#Pad(ale#Var(a:buffer, 'vhdl_ghdl_options')) . ' %t'
endfunction

function! ale_linters#vhdl#ghdl#Handle(buffer, lines) abort
    " Look for 'error' lines like the following:
    " dff_en.vhd:41:5:error: 'begin' is expected instead of 'if'
    " /path/to/file.vhdl:12:8: no declaration for "i0"
    " tb_me_top.vhd:37:10 warning: Instantiating module me_top with dangling input port 1 (rst_n) floating.
    " tb_me_top.vhd:17:9 syntax error
    " memory_single_port.vhd:2:10 syntax error
    " C:\users\tb_me_top.vhd:17:6:20 error: Invalid module instantiation
    "
    " Regex descriptions:
    " ^ start of line
    " \s*      0 or more whitespaces
    " \u\=     0 or 1 Uppercase letter (for Drive letter)
    " :\=      0 or 1 colon (for Drive letter)
    " [^:]\+   1 or more greedy any character EXCEPT colon
    " :\(\d\+\) Capture number(line num) after first colon
    " :\(\d\+\) Capture number(column/row num) after second colon
    " : \(.\+\) Capture rest of message string
    let l:pattern = '^\s*\u\=:\=[^:]\+:\(\d\+\):\(\d\+\):\s*\(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col' : l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction


call ale#linter#Define('vhdl', {
\   'name': 'ghdl',
\   'output_stream': 'stderr',
\   'executable': {b -> ale#Var(b, 'vhdl_ghdl_executable')},
\   'command': function('ale_linters#vhdl#ghdl#GetCommand'),
\   'callback': 'ale_linters#vhdl#ghdl#Handle',
\})
