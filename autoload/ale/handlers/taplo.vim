" Author: Jeremy Cantrell <jmcantrell@gmail.com>
" Description: A versatile, feature-rich TOML toolkit

call ale#Set('taplo_executable', 'taplo')

function! ale#handlers#taplo#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'taplo_executable')
endfunction
