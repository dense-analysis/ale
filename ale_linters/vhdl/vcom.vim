" Author:      John Gentile <johncgentile17@gmail.com>
" Description: Adds support for Mentor Graphics Questa/ModelSim `vcom` VHDL compiler/checker

call ale#Set('vhdl_vcom_executable', 'vcom')
" Use VHDL-2008. See `$ vcom -h` for more options
call ale#Set('vhdl_vcom_options', '-2008 -quiet -lint')

function! ale_linters#vhdl#vcom#GetCommand(buffer) abort
    return '%e ' . ale#Pad(ale#Var(a:buffer, 'vhdl_vcom_options')) . ' %t'
endfunction

function! ale_linters#vhdl#vcom#Handle(buffer, lines) abort
    "Matches patterns like the following:
    "** Warning: ../path/to/file.vhd(218): (vcom-1236) Shared variables must be of a protected type.
    "** Error: tb_file.vhd(73): (vcom-1136) Unknown identifier "aresetn".
    "** Error: tb_file.vhd(73): Bad resolution function (STD_LOGIC) for type (error).
    "** Error: tb_file.vhd(73): near ":": (vcom-1576) expecting ';' or ')'.
    "** Error: C:\Users\avander\AppData\Local\Temp\VICE0F.tmp\file.vhd(25): Unknown expanded name
    "** Error (suppressible): C:\Users\avander\AppData\Local\Temp\VICE0F.tmp\file.vhd(25):
    "                         (vcom-1195) Cannot find expanded name "work.Pkgpackage".
    "
    "Regex description:
    "^          Start of line
    "**         vcom message leader literal
    "\s         single whitespace
    "\([^:]\+\) Capture 1 or more greedy any character EXCEPT colon
    ":\s        Colon and single whitespace
    "[^(]\+     1 or more greedy any character EXCEPT open parentheses
    "(\(\d\+\)) Capture line number in parentheses
    ":\s\+      Colon and whitespace
    "\(.*\)     Capture rest of message string
    let l:pattern = '^**\s\([^:]\+\):\s[^(]\+(\(\d\+\)):\s\+\(.*\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'type': l:match[1] is? 'Warning' ? 'W' : 'E',
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('vhdl', {
\   'name': 'vcom',
\   'output_stream': 'stdout',
\   'executable': {b -> ale#Var(b, 'vhdl_vcom_executable')},
\   'command': function('ale_linters#vhdl#vcom#GetCommand'),
\   'callback': 'ale_linters#vhdl#vcom#Handle',
\})
