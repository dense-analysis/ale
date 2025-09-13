" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: Integration of tombi formatting with ALE.

call ale#Set('toml_tombi_executable', 'tombi')
call ale#Set('toml_tombi_format_options', '')

function! ale#fixers#tombi_format#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'toml_tombi_executable')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' format'
    \       . ale#Pad(ale#Var(a:buffer, 'toml_tombi_format_options')),
    \}
endfunction
