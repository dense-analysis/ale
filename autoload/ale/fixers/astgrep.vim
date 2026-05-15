" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: Fix files with `ast-grep`.

call ale#Set('astgrep_executable', 'ast-grep')
call ale#Set('astgrep_scan_options', '--update-all')

function! ale#fixers#astgrep#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'astgrep_executable')
    let l:options = ale#Var(a:buffer, 'astgrep_scan_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' scan'
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
