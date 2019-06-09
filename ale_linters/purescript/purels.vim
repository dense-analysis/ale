" Author: Drew Olson <drew@drewolson.org>
" Description: Integrate ALE with purescript-language-server.

call ale#Set('purescript_purels_executable', 'purescript-language-server')
call ale#Set('purescript_purels_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('purescript_purels_config', {})

function! ale_linters#purescript#purels#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'purescript_purels', [
    \   'node_modules/.bin/purescript-language-server',
    \])
endfunction

function! ale_linters#purescript#purels#GetCommand(buffer) abort
    let l:executable = ale_linters#purescript#purels#GetExecutable(a:buffer)

    return ale#Escape(l:executable) . ' --stdio'
endfunction

function! ale_linters#purescript#purels#FindProjectRoot(buffer) abort
    let l:pure_config = ale#path#FindNearestFile(a:buffer, 'bower.json')

    if !empty(l:pure_config)
        return fnamemodify(l:pure_config, ':h')
    endif

    let l:pure_config = ale#path#FindNearestFile(a:buffer, 'psc-package.json')

    if !empty(l:pure_config)
        return fnamemodify(l:pure_config, ':h')
    endif

    let l:pure_config = ale#path#FindNearestFile(a:buffer, 'spago.dhall')

    if !empty(l:pure_config)
        return fnamemodify(l:pure_config, ':h')
    endif

    return ''
endfunction

call ale#linter#Define('purescript', {
\   'name': 'purels',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#purescript#purels#GetExecutable'),
\   'command': function('ale_linters#purescript#purels#GetCommand'),
\   'project_root': function('ale_linters#purescript#purels#FindProjectRoot'),
\   'lsp_config': {b -> ale#Var(b, 'purescript_purels_config')},
\   'language': 'purescript',
\})
