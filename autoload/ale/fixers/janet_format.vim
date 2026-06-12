" Author: David Gouch <dgouch@gmail.com>
" Description: Format with janet-format https://github.com/janet-lang/spork

call ale#Set('janet_janet_format_executable', 'janet-format')

function! ale#fixers#janet_format#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'janet_janet_format_executable')

    return {
    \   'command': ale#Escape(l:executable) . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
