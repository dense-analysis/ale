" Author: Johan Larsson <johan@jolars.co>
" Description: A language server, formatter, and linter for Julia

call ale#Set('julia_fatou_executable', 'fatou')

function! ale_linters#julia#fatou#GetProjectRoot(buffer) abort
    let l:config = ale#path#FindNearestFile(a:buffer, 'fatou.toml')

    return !empty(l:config) ? fnamemodify(l:config, ':h') : ''
endfunction

call ale#linter#Define('julia', {
\   'name': 'fatou',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'julia_fatou_executable')},
\   'command': '%e lsp',
\   'project_root': function('ale_linters#julia#fatou#GetProjectRoot'),
\})
