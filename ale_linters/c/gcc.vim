if exists('g:loaded_ale_linters_c_gcc')
    finish
endif

let g:loaded_ale_linters_c_gcc = 1

" Set this option to change the GCC options for warnings for C.
if !exists('g:ale_c_gcc_options')
    let g:ale_c_gcc_options = '-Wall'
endif

function! ale_linters#c#gcc#Handle(buffer, lines)
    " Look for lines like the following.
    "
    " <stdin>:8:5: warning: conversion lacks type at end of format [-Wformat=]
    " <stdin>:10:27: error: invalid operands to binary - (have ‘int’ and ‘char *’)
    let pattern = '^<stdin>:\(\d\+\):\(\d\+\): \(warning\|error\): \(.\+\)$'
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
        \   'type': l:match[3] ==# 'warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('c', {
\   'name': 'gcc',
\   'output_stream': 'stderr',
\   'executable': 'gcc',
\   'command': 'gcc -S -x c -fsyntax-only '
\       . g:ale_c_gcc_options
\       . ' -',
\   'callback': 'ale_linters#c#gcc#Handle',
\})
