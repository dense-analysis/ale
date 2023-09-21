" Author: Yining <zhang.yining@gmail.com>
" Description: ruff format as ALE fixer for python files

call ale#Set('python_ruff_executable', 'ruff')
call ale#Set('python_ruff_format_options', '')
call ale#Set('python_ruff_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_ruff_change_directory', 1)
call ale#Set('python_ruff_auto_pipenv', 0)
call ale#Set('python_ruff_auto_poetry', 0)

function! ale#fixers#ruff_format#GetCwd(buffer) abort
    if ale#Var(a:buffer, 'python_ruff_change_directory')
        " Run from project root if found, else from buffer dir.
        let l:project_root = ale#python#FindProjectRoot(a:buffer)

        return !empty(l:project_root) ? l:project_root : '%s:h'
    endif

    return '%s:h'
endfunction

function! ale#fixers#ruff_format#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_ruff_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_ruff_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_ruff', ['ruff'])
endfunction

function! ale#fixers#ruff_format#GetCommand(buffer) abort
    let l:executable = ale#fixers#ruff_format#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? 'pipenv\|poetry$'
    \   ? ' run ruff'
    \   : ''

    return ale#Escape(l:executable) . l:exec_args
endfunction

function! ale#fixers#ruff_format#FixForVersion(buffer, version) abort
    let l:executable = ale#fixers#ruff_format#GetExecutable(a:buffer)
    let l:cmd = [ale#Escape(l:executable)]

    if l:executable =~? 'pipenv\|poetry$'
        call extend(l:cmd, ['run', 'ruff'])
    endif

    let l:fname = expand('#' . a:buffer . '...')

    call add(l:cmd, 'format')

    let l:options = ale#Var(a:buffer, 'python_ruff_format_options')

    if !empty(l:options)
        call add(l:cmd, l:options)
    endif

    call add(l:cmd, '-')

    return {
    \   'cwd': ale#fixers#ruff_format#GetCwd(a:buffer),
    \   'command': join(l:cmd, ' '),
    \}
endfunction

function! ale#fixers#ruff_format#Fix(buffer) abort
    let l:executable = ale#fixers#ruff_format#GetExecutable(a:buffer)
    let l:command = ale#fixers#ruff_format#GetCommand(a:buffer) . ale#Pad('--version')

    return ale#semver#RunWithVersionCheck(
    \     a:buffer,
    \     l:executable,
    \     l:command,
    \     function('ale#fixers#ruff_format#FixForVersion'),
    \)
endfunction
