" Author: Jelmer Vernooij <jelmer@jelmer.uk>
" Description: Language server for Debian package files

call ale#Set('debupstream_debian_lsp_executable', 'debian-lsp')

function! ale_linters#debupstream#debian_lsp#GetProjectRoot(buffer) abort
    " Find the debian directory
    let l:debian_dir = ale#path#FindNearestDirectory(a:buffer, 'debian')

    if !empty(l:debian_dir)
        return fnamemodify(l:debian_dir, ':h:h')
    endif

    return ''
endfunction

call ale#linter#Define('debupstream', {
\   'name': 'debian_lsp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'debupstream_debian_lsp_executable')},
\   'command': '%e',
\   'project_root': function('ale_linters#debupstream#debian_lsp#GetProjectRoot'),
\})
