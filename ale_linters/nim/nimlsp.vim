" Author: jeremija <https://github.com/jeremija>
" Description: Support for nimlsp (language server for nim)

call ale#Set('nim_nimlsp_nim_sources', '')

function! ale_linters#nim#nimlsp#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')

    if !empty(l:project_root)
        return fnamemodify(l:project_root, ':h:h')
    endif

    return ''
endfunction

call ale#linter#Define('nim', {
\   'name': 'nimlsp',
\   'lsp': 'stdio',
\   'executable': 'nimlsp',
\   'command': {buffer -> '%e' . ale#Pad(ale#Var(buffer, 'nim_nimlsp_nim_sources'))},
\   'language': 'nim',
\   'project_root': function('ale_linters#nim#nimlsp#GetProjectRoot'),
\})
