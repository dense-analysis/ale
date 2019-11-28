" Author: Fernando Garcia Borges <fgborges@pm.me>
" Description: F# Language server intergration for ALE

call ale#Set('fsharp_language_server_assembly', '')
call ale#Set('fsharp_language_server_executable', 'dotnet')

function! ale_linters#fsharp#fsls#GetProjectRoot(buffer) abort
    " TODO: Find nearest project file <project name>.fsproj
    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    return !empty(l:git_path) ? fnamemodify(l:git_path, ':h:h') : ''
endfunction

call ale#linter#Define('fsharp', {
\    'name': 'fsharp-language-server',
\    'lsp': 'stdio',
\    'executable': {b -> ale#Var(b, 'fsharp_language_server_executable') },
\    'command': { b -> '%e ' . ale#Var(b, 'fsharp_language_server_assembly') },
\    'project_root': function('ale_linters#fsharp#fsls#GetProjectRoot'),
\})
