" Author: Johan Niklasson <johan@niklasson-embedded.se>
" Description: openscad-lsp support for OpenSCAD

call ale#Set('openscad_openscad_lsp_executable', 'openscad-lsp')
call ale#Set('openscad_openscad_lsp_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('openscad_openscad_lsp_options', '')

function! ale_linters#openscad#openscad_lsp#GetProjectRoot(buffer) abort
    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    if !empty(l:git_path)
        return fnamemodify(l:git_path, ':h')
    endif

    let l:buf_dir = fnamemodify(bufname(a:buffer), ':p:h')

    return !empty(l:buf_dir) ? l:buf_dir : getcwd()
endfunction

call ale#linter#Define('openscad', {
\   'name': 'openscad_lsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#path#FindExecutable(b, 'openscad_openscad_lsp', [
\       'openscad-lsp',
\   ])},
\   'command': {b -> '%e --stdio' . ale#Pad(ale#Var(b, 'openscad_openscad_lsp_options'))},
\   'project_root': function('ale_linters#openscad#openscad_lsp#GetProjectRoot'),
\})
