" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: Integration of tombi formatting with ALE.

call ale#Set('toml_tombi_executable', 'tombi')
call ale#Set('toml_tombi_format_options', '')
call ale#Set('toml_tombi_online', 0)

function! ale#fixers#tombi_format#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'toml_tombi_executable')
    let l:offline = ''

    if !ale#Var(a:buffer, 'toml_tombi_online')
        let l:offline = '--offline'
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' format'
    \       . ale#Pad(l:offline)
    \       . ale#Pad(ale#Var(a:buffer, 'toml_tombi_format_options')),
    \}
endfunction
