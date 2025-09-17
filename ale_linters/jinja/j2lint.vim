" Description: linter for jinja using j2lint

call ale#Set('jinja_j2lint_executable', 'j2lint')
call ale#Set('jinja_j2lint_options', '')
call ale#Set('jinja_j2lint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('jinja_j2lint_auto_pipenv', 0)
call ale#Set('jinja_j2lint_auto_poetry', 0)
call ale#Set('jinja_j2lint_auto_uv', 0)

function! ale_linters#jinja#j2lint#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'jinja_j2lint_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'jinja_j2lint_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'jinja_j2lint_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'jinja_j2lint', ['j2lint'])
endfunction

function! ale_linters#jinja#j2lint#GetCommand(buffer) abort
    let l:executable = ale_linters#jinja#j2lint#GetExecutable(a:buffer)

    let l:exec_args = l:executable =~? 'pipenv\|poetry\|uv$'
    \   ? ' run j2lint'
    \   : ''

    return ale#Escape(l:executable) . l:exec_args
    \   . ale#Pad(ale#Var(a:buffer, 'jinja_j2lint_options'))
    \   . ' %t'
endfunction

call ale#linter#Define('jinja', {
\   'name': 'j2lint',
\   'executable': function('ale_linters#jinja#j2lint#GetExecutable'),
\   'command': function('ale_linters#jinja#j2lint#GetCommand'),
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
