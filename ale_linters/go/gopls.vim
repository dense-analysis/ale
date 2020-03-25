" Author: w0rp <devw0rp@gmail.com>
" Author: Jerko Steiner <https://github.com/jeremija>
" Description: https://github.com/saibing/gopls

call ale#Set('go_gopls_executable', 'gopls')
call ale#Set('go_gopls_options', '--mode stdio')

function! ale_linters#go#gopls#GetCommand(buffer) abort
    return ale#go#EnvString(a:buffer)
    \   . '%e'
    \   . ale#Pad(ale#Var(a:buffer, 'go_gopls_options'))
endfunction

call ale#linter#Define('go', {
\   'name': 'gopls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'go_gopls_executable')},
\   'command': function('ale_linters#go#gopls#GetCommand'),
\   'project_root': function('ale#go#FindProjectRoot'),
\})
