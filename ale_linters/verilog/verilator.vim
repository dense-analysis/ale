" Author: Masahiro H https://github.com/mshr-h
" Description: verilator for verilog files

function! ale_linters#verilog#verilator#Handle(buffer, lines)
    " Look for lines like the following.
    "
    " %Error: addr_gen.v:3: syntax error, unexpected IDENTIFIER
    " %Warning-WIDTH: addr_gen.v:26: Operator ASSIGNDLY expects 12 bits on the Assign RHS, but Assign RHS's CONST '20'h0' generates 20 bits.
    " %Warning-UNUSED: test.v:3: Signal is not used: a
    " %Warning-UNDRIVEN: test.v:3: Signal is not driven: clk
    " %Warning-UNUSED: test.v:4: Signal is not used: dout
    " %Warning-BLKSEQ: test.v:10: Blocking assignments (=) in sequential (flop or latch) block; suggest delayed assignments (<=).
    let l:pattern = '^%\(Warning\|Error\)[^:]*:\([^:]\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[3] + 0
        let l:type = l:match[1] ==# 'Error' ? 'E' : 'W'
        let l:text = l:match[4]
        let l:file = l:match[2]

        if(l:file =~# '_verilator_linted.v')
          call add(l:output, {
                \   'bufnr': a:buffer,
                \   'lnum': l:line,
                \   'vcol': 0,
                \   'col': 1,
                \   'text': l:text,
                \   'type': l:type,
                \   'nr': -1,
                \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('verilog', {
\   'name': 'verilator',
\   'output_stream': 'stderr',
\   'executable': 'verilator',
\   'command': g:ale#util#stdin_wrapper . ' _verilator_linted.v verilator --lint-only -Wall -Wno-DECLFILENAME',
\   'callback': 'ale_linters#verilog#verilator#Handle',
\})
