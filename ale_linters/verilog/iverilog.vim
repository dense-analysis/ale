" Author: Masahiro H https://github.com/mshr-h
" Description: iverilog for verilog files

if exists('g:loaded_ale_linters_verilog_iverilog')
    finish
endif

let g:loaded_ale_linters_verilog_iverilog = 1

function! ale_linters#verilog#iverilog#Handle(buffer, lines)
    " Look for lines like the following.
    "
    " tb_me_top.v:37: warning: Instantiating module me_top with dangling input port 1 (rst_n) floating.
    " tb_me_top.v:17: syntax error
    " memory_single_port.v:2: syntax error
    " tb_me_top.v:17: error: Invalid module instantiation
    let pattern = '^[^:]\+:\(\d\+\): \(warning\|error\|syntax error\)\(: \(.\+\)\)\?'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[1] + 0
        let type = l:match[2] ==# 'warning' ? 'W' : 'E'
        let text = l:match[2] ==# 'syntax error' ? 'syntax error' : l:match[4]

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

call ale#linter#define('verilog', {
\   'name': 'iverilog',
\   'output_stream': 'stderr',
\   'executable': 'iverilog',
\   'command': g:ale#util#stdin_wrapper . ' .v iverilog -t null -Wall',
\   'callback': 'ale_linters#verilog#iverilog#Handle',
\})
