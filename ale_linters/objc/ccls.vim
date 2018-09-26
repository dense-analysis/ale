" Author: Ye Jingchen <ye.jingchen@gmail.com>, Ben Falconer <ben@falconers.me.uk>, jtalowell <jtalowell@protonmail.com>
" Description: A language server for Objective-C

call ale#Set('objc_ccls_executable', 'ccls')
call ale#Set('objc_ccls_init_options', {})

function! ale_linters#objc#ccls#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, '.ccls-root')

    if empty(l:project_root)
        let l:project_root = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')
    endif

    if empty(l:project_root)
        let l:project_root = ale#path#FindNearestFile(a:buffer, '.ccls')
    endif

    return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
endfunction

function! ale_linters#objc#ccls#GetInitializationOptions(buffer) abort
    return ale#Var(a:buffer, 'objc_ccls_init_options')
endfunction

call ale#linter#Define('objc', {
\   'name': 'ccls',
\   'lsp': 'stdio',
\   'executable_callback': ale#VarFunc('objc_ccls_executable'),
\   'command': '%e',
\   'project_root_callback': 'ale_linters#objc#ccls#GetProjectRoot',
\   'initialization_options_callback': 'ale_linters#objc#ccls#GetInitializationOptions',
\})
