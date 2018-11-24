" Author: Peter Benjamin <petermbenjamin@gmail.com>
" Description: Integration of mdfmt with ALE.

call ale#Set('markdown_mdfmt_executable', 'mdfmt')
call ale#Set('markdown_mdfmt_options', '')

function! ale#fixers#mdfmt#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'markdown_mdfmt_executable')
    let l:options = ale#Var(a:buffer, 'markdown_mdfmt_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' -l -w'
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
