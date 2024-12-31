scriptencoding utf-8
" Author: Koni Marti <koni.marti@gmail.com>
" Description: Utilities for c3lsp

function! ale#handlers#c3lsp#GetProjectRoot(buffer) abort
    let l:config = ale#path#FindNearestFile(a:buffer, 'project.json')

    if !empty(l:config)
        return fnamemodify(l:config, ':h')
    endif

    return expand('#' . a:buffer . ':p:h')
endfunction

function! ale#handlers#c3lsp#GetInitOpts(buffer, init_options_var) abort
    let l:init_options = {}

    return extend(l:init_options, ale#Var(a:buffer, a:init_options_var))
endfunction
