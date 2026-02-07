scriptencoding utf-8
" Author: Adrian Vollmer <adrian.vollmer@syss.de>
" Description: Fix markdown files with pymarkdown.

call ale#Set('markdown_pymarkdown_executable', 'pymarkdown')
call ale#Set('markdown_pymarkdown_options', '')
call ale#Set('markdown_pymarkdown_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('markdown_pymarkdown_auto_pipenv', 0)
call ale#Set('markdown_pymarkdown_auto_poetry', 0)
call ale#Set('markdown_pymarkdown_auto_uv', 0)

function! ale#fixers#pymarkdown#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'markdown_pymarkdown_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'markdown_pymarkdown_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'markdown_pymarkdown_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'markdown_pymarkdown', ['pymarkdown'])
endfunction

function! ale#fixers#pymarkdown#Fix(buffer) abort
    let l:executable = ale#fixers#pymarkdown#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'markdown_pymarkdown_options')

    let l:exec_args = l:executable =~? 'pipenv\|poetry\|uv$'
    \   ? ' run pymarkdown'
    \   : ''

    return {
    \   'command': ale#Escape(l:executable) . l:exec_args
    \       . ' fix'
    \       . ale#Pad(l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
