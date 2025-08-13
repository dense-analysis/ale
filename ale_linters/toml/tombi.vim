" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: TOML Formatter / Linter / Language Server

call ale#Set('toml_tombi_executable', 'tombi')
call ale#Set('toml_tombi_lsp_options', '')

function! ale_linters#toml#tombi#GetProjectRoot(buffer) abort
    " Try to find nearest tombi.toml
    let l:tombiconfig_file = ale#path#FindNearestFile(a:buffer, 'tombi.toml')

    if !empty(l:tombiconfig_file)
        return fnamemodify(l:tombiconfig_file . '/', ':p:h:h')
    endif

    " Try to find nearest pyproject.toml
    let l:pyproject_file = ale#path#FindNearestFile(a:buffer, 'pyproject.toml')

    if !empty(l:pyproject_file)
        return fnamemodify(l:pyproject_file . '/', ':p:h:h')
    endif

    " Try to find nearest `git` directory
    let l:gitdir = ale#path#FindNearestFile(a:buffer, '.git')

    if !empty(l:gitdir)
        return fnamemodify(l:gitdir . '/', ':p:h:h')
    endif

    return ''
endfunction

call ale#linter#Define('toml', {
\   'name': 'tombi',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'toml_tombi_executable')},
\   'command': {b -> '%e lsp' . ale#Pad(ale#Var(b, 'toml_tombi_lsp_options'))},
\   'project_root': function('ale_linters#toml#tombi#GetProjectRoot'),
\})
