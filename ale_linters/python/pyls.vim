" Author: aurieh <me@aurieh.me>
" Description: A language server for Python

call ale#Set('python_pyls_executable', 'pyls')

function! ale_linters#python#pyls#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'python_pyls_executable')
endfunction

function! ale_linters#python#pyls#GetLanguage(buffer) abort
    return 'python'
endfunction

function! ale_linters#python#pyls#GetProjectRoot(buffer) abort
    " Start with more generic files
    for l:possible_filename in ['setup.cfg', 'tox.ini', 'flake8.cfg', 'pycodestyle.cfg']
        let l:pyls_file = ale#path#FindNearestFile(a:buffer, l:possible_filename)

        if !empty(l:pyls_file)
            return fnamemodify(l:pyls_file, ':h:h')
        endif
    endfor
    return ''
endfunction

call ale#linter#Define('python', {
\   'name': 'pyls',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#python#pyls#GetExecutable',
\   'command_callback': 'ale_linters#python#pyls#GetExecutable',
\   'language_callback': 'ale_linters#python#pyls#GetLanguage',
\   'project_root_callback': 'ale_linters#python#pyls#GetProjectRoot',
\})
