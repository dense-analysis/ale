" Author: Arnold Chand <creativenull@outlook.com>
" Description: Volar Language Server integration for ALE

call ale#Set('vue_volar_executable', 'volar-server')
call ale#Set('vue_volar_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#vue#volar#GetProjectRoot(buffer) abort
    let l:package_path = ale#path#FindNearestFile(a:buffer, 'package.json')

    return !empty(l:package_path) ? fnamemodify(l:package_path, ':h') : ''
endfunction

call ale#linter#Define('volar', {
\   'name': 'volar-server',
\   'lsp': 'stdio',
\   'executable': {b -> ale#path#FindExecutable(b, 'vue_volar', [
\       'node_modules/.bin/volar-server',
\   ])},
\   'command': '%e --stdio',
\   'language': 'vue',
\   'project_root': function('ale_linters#vue#volar#GetProjectRoot'),
\})
