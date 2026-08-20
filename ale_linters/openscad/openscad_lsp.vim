" Author: Johan Niklasson <johan@niklasson-embedded.se>
" Description: openscad-lsp support for OpenSCAD

call ale#Set('openscad_openscad_lsp_executable', 'openscad-lsp')
call ale#Set('openscad_openscad_lsp_options', '')

function! ale_linters#openscad#openscad_lsp#GetProjectRoot(buffer) abort
    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    if !empty(l:git_path)
        return fnamemodify(l:git_path, ':h:h')
    endif

    return expand('#' . a:buffer . ':p:h')
endfunction

call ale#linter#Define('openscad', {
\   'name': 'openscad_lsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'openscad_openscad_lsp_executable')},
\   'command': {b -> '%e --stdio' . ale#Pad(ale#Var(b, 'openscad_openscad_lsp_options'))},
\   'project_root': function('ale_linters#openscad#openscad_lsp#GetProjectRoot'),
\})
