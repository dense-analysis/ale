" Author: Benjamin Block <https://github.com/benjamindblock>
" Description: A language server for Lean 4.

function! ale_linters#lean#lake#GetProjectRoot(buffer) abort
    let l:lakefile_toml = ale#path#FindNearestFile(a:buffer, 'lakefile.toml')
    let l:lakefile_lean = ale#path#FindNearestFile(a:buffer, 'lakefile.lean')

    if !empty(l:lakefile_toml)
        return fnamemodify(l:lakefile_toml, ':p:h')
    elseif !empty(l:lakefile_lean)
        return fnamemodify(l:lakefile_lean, ':p:h')
    else
        return fnamemodify('', ':h')
    endif
endfunction

call ale#Set('lean_lake_executable', 'lake')
call ale#Set('lean_lake_config', {})

call ale#linter#Define('lean', {
\   'name': 'lake',
\   'lsp': 'stdio',
\   'language': 'lean',
\   'lsp_config': {b -> ale#Var(b, 'lean_lake_config')},
\   'executable': {b -> ale#Var(b, 'lean_lake_executable')},
\   'command': '%e serve',
\   'project_root': function('ale_linters#lean#lake#GetProjectRoot'),
\})
