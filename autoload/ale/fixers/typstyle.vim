" Author: Adrian Vollmer (computerfluesterer@protonmail.com)
" Description: Typst formatter using typstyle

call ale#Set('typst_typstyle_executable', 'typstyle')
call ale#Set('typst_typstyle_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('typst_typstyle_options', '')

function! ale#fixers#typstyle#Fix(buffer) abort
    let l:executable = ale#path#FindExecutable(
    \   a:buffer,
    \   'typst_typstyle',
    \   ['typstyle']
    \)

    let l:options = ale#Var(a:buffer, 'typst_typstyle_options')

    return {
    \   'command': ale#Escape(l:executable) . ' ' . l:options,
    \}
endfunction
