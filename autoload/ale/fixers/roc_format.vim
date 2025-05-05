" Author: Benjamin Block <https://github.com/benjamindblock>
" Description: Official formatter for Roc.

call ale#Set('roc_roc_format_executable', 'roc')
call ale#Set('roc_roc_format_options', '')

function! ale#fixers#roc_format#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'roc_roc_format_executable')
    let l:command = l:executable . ' format'
    let l:options = ale#Var(a:buffer, 'roc_roc_format_options')

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    return {
    \   'command': l:command . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
