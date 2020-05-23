" Author: Luiz Ribeiro <luizribeiro@gmail.com>
" Description: C# support via omnisharp

call ale#Set('cs_omnisharp_mono_executable', 'mono')
call ale#Set('cs_omnisharp_executable', 'OmniSharp.exe')
call ale#Set('cs_omnisharp_options', '-lsp')

function! ale_linters#cs#omnisharp#GetProjectRoot(buffer) abort
    let l:omnisharp_json = ale#path#FindNearestFile(a:buffer, 'omnisharp.json')
    return !empty(l:omnisharp_json) ? fnamemodify(l:omnisharp_json, ':h') : ''
endfunction

function! ale_linters#cs#omnisharp#GetMonoExecutable(buffer) abort
    return ale#Var(a:buffer, 'cs_omnisharp_mono_executable')
endfunction

function! ale_linters#cs#omnisharp#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'cs_omnisharp_executable')
    let l:options = ale#Var(a:buffer, 'cs_omnisharp_options')
    return '%e ' . l:executable . ' ' . l:options
endfunction

call ale#linter#Define('cs', {
\   'name': 'omnisharp',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#cs#omnisharp#GetMonoExecutable'),
\   'command': function('ale_linters#cs#omnisharp#GetCommand'),
\   'project_root': function('ale_linters#cs#omnisharp#GetProjectRoot'),
\})
