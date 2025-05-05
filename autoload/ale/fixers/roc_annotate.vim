" Author: Benjamin Block <https://github.com/benjamindblock>
" Description: Official type annotation tool for Roc.

call ale#Set('roc_roc_annotate_executable', 'roc')
call ale#Set('roc_roc_annotate_options', '')

function! ale#fixers#roc_annotate#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'roc_roc_annotate_executable')
    let l:command = l:executable . ' format annotate'
    let l:options = ale#Var(a:buffer, 'roc_roc_annotate_options')

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    return {
    \   'command': l:command . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction

