" Author: Devon Meunier <devon.meunier@gmail.com>
" Description: Support for python-language-server https://github.com/palantir/python-language-server

call ale#Set('python_langserver_executable', 'pyls')
call ale#Set('python_langserver_options', '')

function! ale_linters#python#langserver#GetCommand(buffer) abort
    let l:executable = [ale#Escape(ale#Var(a:buffer, 'python_langserver_executable'))]
    let l:options = ale#Var(a:buffer, 'python_langserver_options')
    let l:options = filter(split(l:options, ' '), 'empty(v:val) != 1')
    let l:options = uniq(sort(l:options))

    return join(extend(l:executable, l:options), ' ')
endfunction

call ale#linter#Define('python', {
\   'name': 'python-language-server',
\   'lsp': 'stdio',
\   'executable_callback': ale#VarFunc('python_langserver_executable'),
\   'command_callback': 'ale_linters#python#langserver#GetCommand',
\   'project_root_callback': 'ale#python#FindProjectRoot',
\})
