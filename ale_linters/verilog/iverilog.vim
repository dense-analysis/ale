" Author: Masahiro H https://github.com/mshr-h
" Description: iverilog for verilog files

function! ale_linters#verilog#iverilog#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " tb_me_top.v:37: warning: Instantiating module me_top with dangling input port 1 (rst_n) floating.
    " tb_me_top.v:17: syntax error
    " memory_single_port.v:2: syntax error
    " tb_me_top.v:17: error: Invalid module instantiation
    let l:pattern = '^[^:]\+:\(\d\+\): \(warning\|error\|syntax error\)\(: \(.\+\)\)\?'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:type = l:match[2] =~# 'error' ? 'E' : 'W'
        let l:text = l:match[2] ==# 'syntax error' ? 'syntax error' : l:match[4]

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'col': 1,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('verilog', {
\   'name': 'iverilog',
\   'output_stream': 'stderr',
\   'executable': 'iverilog',
\   'command': 'iverilog -t null -Wall %t',
\   'callback': 'ale_linters#verilog#iverilog#Handle',
\})
