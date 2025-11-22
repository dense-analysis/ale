call ale#Set('python_unimport_executable', 'unimport')
call ale#Set('python_unimport_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_unimport_options', '')
call ale#Set('python_unimport_auto_pipenv', 0)
call ale#Set('python_unimport_auto_poetry', 0)
call ale#Set('python_unimport_auto_uv', 0)

function! ale#fixers#unimport#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_unimport_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_unimport_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'python_unimport_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_unimport', ['unimport'])
endfunction

function! ale#fixers#unimport#Fix(buffer) abort
    let l:executable = ale#fixers#unimport#GetExecutable(a:buffer)
    let l:cmd = [ale#Escape(l:executable)]

    if l:executable =~? '\(pipenv\|poetry\|uv\)$'
        call extend(l:cmd, ['run', 'unimport'])
    endif

    let l:options = ale#Var(a:buffer, 'python_unimport_options')

    if !empty(l:options)
        call add(l:cmd, l:options)
    endif

    return {'command': join(l:cmd, ' ')}
endfunction
