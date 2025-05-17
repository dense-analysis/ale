" Author: oliverralbertini <oliver.albertini@gmail.com>
" Description: A performant type-checker supporting LSP for Python 3 created by Facebook

call ale#Set('python_pyrefly_executable', 'pyrefly')
call ale#Set('python_pyrefly_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_pyrefly_auto_pipenv', 0)
call ale#Set('python_pyrefly_auto_poetry', 0)
call ale#Set('python_pyrefly_auto_uv', 0)

function! ale_linters#python#pyrefly#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_pyrefly_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_pyrefly_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'python_pyrefly_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_pyrefly', ['pyrefly'])
endfunction

function! ale_linters#python#pyrefly#GetCommand(buffer) abort
    let l:executable = ale_linters#python#pyrefly#GetExecutable(a:buffer)
    let l:exec_args = [
    \ ale#Escape(l:executable)
    \ ]
    \ + (l:executable =~? '\(pipenv\|poetry\|uv\)$' ? ['run', 'pyrefly'] : [])
    \ + [
    \ 'lsp',
    \ ]

    return join(l:exec_args, ' ')
endfunction

function! ale_linters#python#pyrefly#GetCwd(buffer) abort
    " Run from project root if found, else from buffer dir.
    let l:project_root = ale#python#FindProjectRoot(a:buffer)

    return !empty(l:project_root) ? l:project_root : '%s:h'
endfunction

call ale#linter#Define('python', {
\   'name': 'pyrefly',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#python#pyrefly#GetExecutable'),
\   'command': function('ale_linters#python#pyrefly#GetCommand'),
\   'project_root': function('ale#python#FindProjectRoot'),
\   'completion_filter': 'ale#completion#python#CompletionItemFilter',
\   'cwd': function('ale_linters#python#pyrefly#GetCwd'),
\})
