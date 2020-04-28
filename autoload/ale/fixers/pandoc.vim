scriptencoding utf-8
" Author: Dongsheng Cai <d@tux.im>
" Description: Fix plaintext formats with pandoc.

call ale#Set('pandoc_executable', 'pandoc')
call ale#Set('pandoc_options', '')
call ale#Set('pandoc_use_gfm', 1)

function! s:TransformOptions(buffer) abort
    let l:use_gfm = ale#Var(a:buffer, 'pandoc_use_gfm')
    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:ft = l:filetype =~? '^markdown' && l:use_gfm
    \   ? 'gfm'
    \   : l:filetype

    let l:args = ' -f ' . l:ft . ' -t ' . l:ft

    return l:args
endfunction

function! ale#fixers#pandoc#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'pandoc_executable')
    let l:options = ale#Var(a:buffer, 'pandoc_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . s:TransformOptions(a:buffer)
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \}
endfunction
