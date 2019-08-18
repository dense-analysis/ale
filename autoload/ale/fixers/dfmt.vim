" Author: Björn Lindström <bkhl@elektrubadur.se>
" Description: Fixing D files with dfmt

call ale#Set('d_dfmt_executable', 'dfmt')
call ale#Set('d_dfmt_options', '')

function! ale#fixers#dfmt#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'd_dfmt_executable')
    let l:options = ale#Var(a:buffer, 'd_dfmt_options')

    return {
    \   'command': ale#path#BufferCdString(a:buffer)
    \   .   ale#Escape(l:executable) . (!empty(l:options) ? ' ' . l:options : ''),
    \}
endfunction
