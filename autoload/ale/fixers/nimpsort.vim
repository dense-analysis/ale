" Author: cycneuramus <cycneuramus@users.noreply.github.com>
" Description: Integration of nimpsort with ALE.

call ale#Set('nim_nimpsort_executable', 'nimpsort')

function! ale#fixers#nimpsort#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'nim_nimpsort_executable')

    return {
    \   'command': ale#Escape(l:executable) . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
