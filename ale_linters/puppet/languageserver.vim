" Author: Alexander Olofsson <alexander.olofsson@liu.se>
" Description: Puppet Language Server integration for ALE

call ale#Set('puppet_languageserver_executable', 'puppet-languageserver')

function! ale_linters#puppet#languageserver#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'puppet_languageserver_executable')
endfunction

function! ale_linters#puppet#languageserver#GetCommand(buffer) abort
    let l:exe = ale#Escape(ale_linters#puppet#languageserver#GetExecutable(a:buffer))

    return l:exe . ' --stdio'
endfunction

function! ale_linters#puppet#languageserver#GetProjectRoot(buffer) abort
    " Note: while manifest.json is a strong recommendation, the only
    " *required* path for a Puppet module is the manifests folder.
    let l:root_path = ale#path#FindNearestFile(a:buffer, 'metadata.json')

    if empty(l:root_path)
        let l:root_path = ale#path#FindNearestDirectory(a:buffer, 'manifests')
    endif

    return !empty(l:root_path) ? fnamemodify(l:root_path, ':h') : ''
endfunction

call ale#linter#Define('puppet', {
\   'name': 'languageserver',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#puppet#languageserver#GetExecutable',
\   'command_callback': 'ale_linters#puppet#languageserver#GetCommand',
\   'language': 'puppet',
\   'project_root_callback': 'ale_linters#puppet#languageserver#GetProjectRoot',
\})
