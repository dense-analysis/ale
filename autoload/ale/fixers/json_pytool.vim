" Author: idbrii
" Description: json formatter as ALE fixer using python's json.tool

call ale#Set('json_pytool_executable', 'python')
call ale#Set('json_pytool_options', '')
call ale#Set('json_pytool_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#json_pytool#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'json_pytool', ['python'])
endfunction

function! ale#fixers#json_pytool#Fix(buffer) abort
    let l:executable = ale#Escape(ale#fixers#json_pytool#GetExecutable(a:buffer))
    let l:opts = ale#Var(a:buffer, 'json_pytool_options')
    let l:command = printf('%s -m json.tool %s -', l:executable, l:opts)

    return {
    \   'command': l:command
    \ }
endfunction
