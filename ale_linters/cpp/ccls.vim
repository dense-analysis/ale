" Author: Ye Jingchen <ye.jingchen@gmail.com>, Ben Falconer <ben@falconers.me.uk>, jtalowell <jtalowell@protonmail.com>
" Description: A language server for C++

call ale#Set('cpp_ccls_executable', 'ccls')
call ale#Set('cpp_ccls_init_options', {})

function! ale_linters#cpp#ccls#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, '.ccls-root')

    if empty(l:project_root)
        let l:project_root = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')
    elseif empty(l:project_root)
        let l:project_root = ale#path#FindNearestFile(a:buffer, '.ccls')
    endif

    return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
endfunction

function! ale_linters#cpp#ccls#GetInitializationOptions(buffer) abort
    return ale#Var(a:buffer, 'cpp_ccls_init_options')
endfunction

call ale#linter#Define('cpp', {
\   'name': 'ccls',
\   'lsp': 'stdio',
\   'executable_callback': ale#VarFunc('cpp_ccls_executable'),
\   'command': '%e',
\   'project_root_callback': 'ale_linters#cpp#ccls#GetProjectRoot',
\   'initialization_options_callback': 'ale_linters#cpp#ccls#GetInitializationOptions',
\})
