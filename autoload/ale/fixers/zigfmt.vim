scriptencoding utf-8
" Author: Arash Mousavi <arash-m>
" Description: Official formatter for Zig.

call ale#Set('zig_zig_executable', 'zig')

function! ale#fixers#zigfmt#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'zig_zig_executable')

    return {
    \   'command': ale#Escape(l:executable) . ' fmt %t',
    \   'read_temporary_file': 1,
    \}
endfunction
