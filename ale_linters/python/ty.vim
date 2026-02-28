" Description: ty as linter for python files

call ale#Set('python_ty_executable', 'ty')
call ale#Set('python_ty_options', '')
call ale#Set('python_ty_use_global', get(g:, 'ale_use_global_executables', 1))
call ale#Set('python_ty_change_directory', 1)
call ale#Set('python_ty_auto_pipenv', 0)
call ale#Set('python_ty_auto_poetry', 0)
call ale#Set('python_ty_auto_uv', 0)

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

function! ale_linters#python#ty#GetCwd(buffer) abort
    if ale#Var(a:buffer, 'python_ty_change_directory')
        " Run from project root if found, else from buffer dir.
        let l:project_root = ale#python#FindProjectRoot(a:buffer)

        return !empty(l:project_root) ? l:project_root : '%s:h'
    endif

    return ''
endfunction

function! ale_linters#python#ty#GetCommand(buffer) abort
    let l:executable = ale_linters#python#ty#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? '\(pipenv\|poetry\|uv\)$' ? ' run ty ' : ''

    let l:exec_args = l:exec_args . ' check --output-format gitlab '

    return ale#Escape(l:executable) . l:exec_args . ale#Pad(ale#Var(a:buffer, 'python_ty_options')) . ' %s'
endfunction

function! ale_linters#python#ty#Handle(buffer, lines) abort
    let l:output = []

    let l:items = json_decode(join(a:lines, ''))

    if empty(l:items)
        return l:output
    endif

    for l:item in l:items
        call add(l:output, {
        \   'lnum': l:item.location.positions.begin.line,
        \   'col': l:item.location.positions.begin.column,
        \   'end_lnum': l:item.location.positions.end.line,
        \   'end_col': l:item.location.positions.end.column,
        \   'code': l:item.check_name,
        \   'text': l:item.description,
        \   'type': l:item.severity =~? 'major' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'ty',
\   'executable': function('ale_linters#python#ty#GetExecutable'),
\   'cwd': function('ale_linters#python#ty#GetCwd'),
\   'command': function('ale_linters#python#ty#GetCommand'),
\   'callback': 'ale_linters#python#ty#Handle',
\   'output_stream': 'stdout',
\})
