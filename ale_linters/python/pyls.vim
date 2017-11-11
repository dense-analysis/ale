" Author: aurieh <me@aurieh.me>
" Description: A language server for Python

call ale#Set('python_pyls_executable', 'pyls')

function! ale_linters#python#pyls#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'python_pyls_executable')
endfunction

function! ale_linters#python#pyls#GetLanguage(buffer) abort
    return 'python'
endfunction

call ale#linter#Define('python', {
\   'name': 'pyls',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#python#pyls#GetExecutable',
\   'command_callback': 'ale_linters#python#pyls#GetExecutable',
\   'language_callback': 'ale_linters#python#pyls#GetLanguage',
\   'project_root_callback': 'ale#python#FindProjectRoot',
\})
