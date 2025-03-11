" Author: tony o'dell <tony.odell@live.com>
" Description: Fix scad files with scadformat

call ale#Set('openscad_scadformat_executable', 'scadformat')
call ale#Set('openscad_scadformat_options', '')

function! ale#fixers#scadformat#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'openscad_scadformat_executable')
    let l:options = ale#Var(a:buffer, 'openscad_scadformat_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . (empty(l:options) ? '' : ' ' . l:options),
    \}
endfunction
