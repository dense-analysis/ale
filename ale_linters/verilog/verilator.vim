" Author: Masahiro H https://github.com/mshr-h
" Description: verilator for verilog files

if exists('g:loaded_ale_linters_verilog_verilator')
    finish
endif

let g:loaded_ale_linters_verilog_verilator = 1

function! ale_linters#verilog#verilator#Handle(buffer, lines)
    " Look for lines like the following.
    "
    " %Error: addr_gen.v:3: syntax error, unexpected IDENTIFIER
    " %Warning-WIDTH: addr_gen.v:26: Operator ASSIGNDLY expects 12 bits on the Assign RHS, but Assign RHS's CONST '20'h0' generates 20 bits.
    " %Warning-UNUSED: test.v:3: Signal is not used: a
    " %Warning-UNDRIVEN: test.v:3: Signal is not driven: clk
    " %Warning-UNUSED: test.v:4: Signal is not used: dout
    " %Warning-BLKSEQ: test.v:10: Blocking assignments (=) in sequential (flop or latch) block; suggest delayed assignments (<=).
    let pattern = '^%\(Warning\|Error\)[^:]*:[^:]\+:\(\d\+\): \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[2] + 0
        let type = l:match[1] ==# 'Error' ? 'E' : 'W'
        let text = l:match[3]

        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': 1,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#Define('verilog', {
\   'name': 'verilator',
\   'output_stream': 'stderr',
\   'executable': 'verilator',
\   'command': g:ale#util#stdin_wrapper . ' .v verilator --lint-only -Wall -Wno-DECLFILENAME',
\   'callback': 'ale_linters#verilog#verilator#Handle',
\})
