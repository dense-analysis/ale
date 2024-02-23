" Author: Jeremy Cantrell <jmcantrell@gmail.com>
" Description: A versatile, feature-rich TOML toolkit

function! ale#fixers#taplo#Fix(buffer) abort
    let l:executable = ale#handlers#taplo#GetExecutable(a:buffer)

    return {
    \   'command': ale#Escape(l:executable) . ' format -'
    \}
endfunction
