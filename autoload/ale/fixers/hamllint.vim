" Author: Francis Perez - https://github.com/ciscou
" Description: Fix Haml files with haml-lint --auto-correct-only.

call ale#Set('haml_hamllint_executable', 'haml-lint')

function! ale#fixers#hamllint#Fix(buffer) abort
    return {
    \   'command': ale#Escape(ale#Var(a:buffer, 'haml_hamllint_executable'))
    \       . ' --auto-correct-only --stderr --stdin %s',
    \}
endfunction
