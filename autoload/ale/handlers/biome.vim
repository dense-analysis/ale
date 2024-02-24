" Author: Filip Gospodinov <f@gospodinov.ch>
" Description: Functions for working with biome, for checking or fixing files.

call ale#Set('biome_executable', 'biome')
call ale#Set('biome_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('biome_options', '')

function! ale#handlers#biome#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'biome', [
    \   'node_modules/@biomejs/cli-linux-x64/biome',
    \   'node_modules/@biomejs/cli-linux-arm64/biome',
    \   'node_modules/@biomejs/cli-win32-x64/biome.exe',
    \   'node_modules/@biomejs/cli-win32-arm64/biome.exe',
    \   'node_modules/@biomejs/cli-darwin-x64/biome',
    \   'node_modules/@biomejs/cli-darwin-arm64/biome',
    \   'node_modules/.bin/biome',
    \])
endfunction

function! ale#handlers#biome#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'biome_options')

    return '%e lsp-proxy'
    \   . (!empty(l:options) ? ' ' . l:options : '')
endfunction

function! ale#handlers#biome#GetProjectRoot(buffer) abort
    let l:biome_file = ale#path#FindNearestFile(a:buffer, 'biome.json')

    return !empty(l:biome_file) ? fnamemodify(l:biome_file, ':h') : ''
endfunction
