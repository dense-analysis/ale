" Author: hsanson <hsanson@gmail.com>
" Description: kulala_fmt fixer for http and rest files.

call ale#Set('http_kulala_fmt_executable', 'kulala-fmt')

function! ale#fixers#kulala_fmt#Fix(buffer) abort
    return {
    \ 'command': ale#Escape(ale#Var(a:buffer, 'http_kulala_fmt_executable')) . ' format %t > /dev/null',
    \ 'read_temporary_file': 1
    \ }
endfunction
