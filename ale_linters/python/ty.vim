" Author: w0rp <dev@w0rp.com>
" Description: Astral's Python type checker and language server

call ale#Set('python_ty_executable', 'ty')
call ale#Set('python_ty_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_ty_auto_pipenv', 0)
call ale#Set('python_ty_auto_poetry', 0)
call ale#Set('python_ty_auto_uv', 0)
call ale#Set('python_ty_config', {})

function! ale_linters#python#ty#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_ty_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_ty_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'python_ty_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_ty', ['ty'])
endfunction

" Force the cwd of the server to be the same as the project root.
function! ale_linters#python#ty#GetCwd(buffer) abort
    let l:fake_linter = {
    \   'name': 'ty',
    \   'project_root': function('ale#python#FindProjectRoot'),
    \}
    let l:root = ale#lsp_linter#FindProjectRoot(a:buffer, l:fake_linter)

    return !empty(l:root) ? l:root : v:null
endfunction

function! ale_linters#python#ty#GetCommand(buffer) abort
    let l:executable = ale_linters#python#ty#GetExecutable(a:buffer)
    let l:exec_args = [
    \   ale#Escape(l:executable),
    \]
    \ + (l:executable =~? '\(pipenv\|poetry\|uv\)$' ? ['run', 'ty'] : [])
    \ + [
    \   'server',
    \]

    return join(l:exec_args, ' ')
endfunction

call ale#linter#Define('python', {
\   'name': 'ty',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#python#ty#GetExecutable'),
\   'cwd': function('ale_linters#python#ty#GetCwd'),
\   'command': function('ale_linters#python#ty#GetCommand'),
\   'project_root': function('ale#python#FindProjectRoot'),
\   'completion_filter': 'ale#completion#python#CompletionItemFilter',
\   'lsp_config': {b -> ale#Var(b, 'python_ty_config')},
\})
