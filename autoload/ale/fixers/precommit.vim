" Author: Matthew Grossman <matt@mrgrossman.com>
" Description: Fix multi-language pre-commit hooks


call ale#Set('ale_precommit_executable', 'pre-commit')
call ale#Set('ale_precommit_hooks', [])
call ale#Set('ale_precommit_options', '')

function! ale#fixers#precommit#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'ale_precommit_executable')
    let l:hooks = ale#Var(a:buffer, 'ale_precommit_hooks')
    let l:options = ale#Var(a:buffer, 'ale_precommit_options')
    let l:file_path = ale#Escape(bufname(a:buffer))
    let l:command = ''

    if empty(l:hooks)
        let l:command = l:executable . ' run --files ' . l:file_path
    else
        for l:hook in l:hooks
            let l:command .= l:executable . ' run ' . l:hook . ' --files ' . l:file_path . ';'
        endfor
    endif

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    return {'command': ale#Escape(l:command)}
endfunction
