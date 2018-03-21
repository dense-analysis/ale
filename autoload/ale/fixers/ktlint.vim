" Author: Paolo Gavocanov <gavocanov@gmail.com>
" Description: Integration of ktlint with ALE.

call ale#Set('kotlin_ktlint_executable', 'ktlint')
call ale#Set('kotlin_ktlint_rulesets', [])

function! ale#fixers#ktlint#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'kotlin_ktlint_executable')
    for l:ruleset in ale#Var(a:buffer, 'kotlin_ktlint_rulesets')
        let l:options = l:options . ' --ruleset ' . l:ruleset
    endfor

    return {
    \   'command': ale#Escape(l:executable)
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \       . ' -F'
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction

