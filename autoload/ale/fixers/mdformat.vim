" Author: Horacio
" Description: Fix Markdown files with mdformat.

call ale#Set('markdown_mdformat_executable', 'mdformat')
call ale#Set('markdown_mdformat_options', '')
call ale#Set('markdown_mdformat_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('markdown_mdformat_auto_pipenv', 0)
call ale#Set('markdown_mdformat_auto_poetry', 0)
call ale#Set('markdown_mdformat_auto_uv', 0)

function! ale#fixers#mdformat#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'markdown_mdformat_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'markdown_mdformat_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'markdown_mdformat_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'markdown_mdformat', ['mdformat'])
endfunction

function! ale#fixers#mdformat#Fix(buffer) abort
    let l:executable = ale#fixers#mdformat#GetExecutable(a:buffer)
    let l:command = ale#Escape(l:executable)

    if l:executable =~? '\(pipenv\|poetry\|uv\)$'
        let l:command .= ' run mdformat'
    endif

    return {
    \   'command': l:command
    \       . ale#Pad(ale#Var(a:buffer, 'markdown_mdformat_options'))
    \       . ' -',
    \}
endfunction
