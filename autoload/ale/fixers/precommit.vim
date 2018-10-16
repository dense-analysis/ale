" Author: Matthew Grossman <matt@mrgrossman.com>
" Description: Fix multi-language pre-commit hooks


call ale#Set('precommit_executable', 'pre-commit')
call ale#Set('precommit_hooks', [])
call ale#Set('precommit_options', '')

function! ale#fixers#precommit#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'precommit_executable')
    let l:hooks = ale#Var(a:buffer, 'precommit_hooks')
    let l:options = ale#Var(a:buffer, 'precommit_options')
    let l:command = ''

    if empty(l:hooks)
        let l:command = ale#Escape(l:executable) . ' run --files %t'
                    \ . (!empty(l:options) ? ' ' . l:options : '')
    else
        for l:hook in l:hooks
            let l:command .= ale#Escape(l:executable)
                        \ . ' run ' . l:hook . ' --files %t'
                        \ . (!empty(l:options) ? ' ' . l:options : '') . ';'
        endfor
    endif

    return {'command': l:command}
endfunction
