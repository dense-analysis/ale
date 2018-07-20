" Author: David Komer <david.komer@gmail.com> 
" Description: Integrate ALE with purescript-language-server.

call ale#Set('pure_ls_executable', 'purescript-language-server')
call ale#Set('pure_ls_use_global',
\    get(g:, 'ale_use_global_executables', 0)
\)

function! ale_linters#purescript#pure_ls#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'pure_ls', [
    \   'node_modules/.bin/purescript-language-server',
    \])
endfunction

function! ale_linters#purescript#pure_ls#GetCommand(buffer) abort
    let l:executable = ale_linters#purescript#pure_ls#GetExecutable(a:buffer)

    return ale#Escape(l:executable) . ' --stdio --config ' . ale#Escape('{}')
endfunction

function! ale_linters#purescript#pure_ls#FindProjectRoot(buffer) abort
    let l:pure_config = ale#path#FindNearestFile(a:buffer, 'psc-package.json')

    if !empty(l:pure_config)
        return fnamemodify(l:pure_config, ':h')
    endif

    return ''
endfunction

call ale#linter#Define('purescript', {
\   'name': 'pure_ls',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#purescript#pure_ls#GetExecutable',
\   'command_callback': 'ale_linters#purescript#pure_ls#GetCommand',
\   'project_root_callback': 'ale_linters#purescript#pure_ls#FindProjectRoot',
\   'language': 'purescript',
\   'output_stream': 'both'
\})
