" Author: Johan Larsson <johan@jolars.co>
" Description: Format Julia files with fatou.

call ale#Set('julia_fatou_executable', 'fatou')
call ale#Set('julia_fatou_options', '')

function! ale#fixers#fatou#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'julia_fatou_executable')
    let l:options = ale#Var(a:buffer, 'julia_fatou_options')

    return {
    \   'command': ale#Escape(l:executable) . ' format'
    \       . ale#Pad(l:options),
    \}
endfunction
