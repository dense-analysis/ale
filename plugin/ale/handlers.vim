" Author: w0rp <devw0rp@gmail.com>
" Description: This file defines some standard error format handlers. Any
"   linter which outputs warnings and errors in a format accepted by one of
"   these functions can simply use one of these pre-defined error handlers.

if exists('g:loaded_ale_handlers')
    finish
endif

let g:loaded_ale_handlers = 1

function! ale#handlers#HandleGCCFormat(buffer, lines)
    " Look for lines like the following.
    "
    " <stdin>:8:5: warning: conversion lacks type at end of format [-Wformat=]
    " <stdin>:10:27: error: invalid operands to binary - (have ‘int’ and ‘char *’)
    " -:189:7: note: $/${} is unnecessary on arithmetic variables. [SC2004]
    let pattern = '^[^:]\+:\(\d\+\):\(\d\+\): \([^:]\+\): \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3] ==# 'error' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction
