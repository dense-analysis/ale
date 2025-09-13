" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: Integration of tombi linting with ALE.

call ale#Set('toml_tombi_executable', 'tombi')
call ale#Set('toml_tombi_lint_options', '')

function! ale#fixers#tombi_lint#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'toml_tombi_executable')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' lint'
    \       . ale#Pad(ale#Var(a:buffer, 'toml_tombi_lint_options')),
    \}
endfunction
