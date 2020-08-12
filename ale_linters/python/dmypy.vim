" Author: Keith Smiley <k@keith.so>, w0rp <devw0rp@gmail.com>, davidatbu <davidat@bu.edu>
" Description: dmypy (mypy daemon) support for optional python typechecking

call ale#Set('python_dmypy_executable', 'dmypy')
call ale#Set('python_dmypy_options', '')
call ale#Set('python_dmypy_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_dmypy_auto_pipenv', 0)

function! ale_linters#python#dmypy#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_dmypy_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_dmypy', ['dmypy'])
endfunction

" The directory to change to before running dmypy
function! s:GetDir(buffer) abort
    " If we find a directory with ".dmypy.json" in it use that,
    " else try and find the "python project" root, or failing
    " that, run from the same folder as the current file
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        if filereadable(l:path . '/.dmypy.json')
            return l:path
        endif
    endfor

    let l:project_root = ale#python#FindProjectRoot(a:buffer)

    return !empty(l:project_root)
    \   ? l:project_root
    \   : expand('#' . a:buffer . ':p:h')
endfunction

function! ale_linters#python#dmypy#GetCommand(buffer) abort
    let l:dir = s:GetDir(a:buffer)
    let l:executable = ale_linters#python#dmypy#GetExecutable(a:buffer)

    let l:exec_args = l:executable =~? 'pipenv$'
    \   ? ' run dmypy'
    \   : ''

    " We have to always switch to an explicit directory for a command so
    " we can know with certainty the base path for the 'filename' keys below.
    return ale#path#CdString(l:dir)
    \   . ale#Escape(l:executable) . l:exec_args
    \   . ' run '
    \   . ale#Var(a:buffer, 'python_dmypy_options')
    \   . ' -- --show-column-numbers '
    \   . ale#Var(a:buffer, 'python_mypy_options')
    \   . ' --shadow-file %s %t %s'
endfunction

call ale#linter#Define('python', {
\   'name': 'dmypy',
\   'executable': function('ale_linters#python#dmypy#GetExecutable'),
\   'command': function('ale_linters#python#dmypy#GetCommand'),
\   'callback': 'ale_linters#python#mypy#Handle',
\   'output_stream': 'both',
\})
