" Author: ophirr33 <coghlan.ty@gmail.com>
" Description: TCP lsp client for sbt Server

call ale#Set('java_sbtserver_address', '127.0.0.1:4273')
call ale#Set('java_sbtserver_project_root', '')

function! ale_linters#java#sbtserver#GetProjectRoot(buffer) abort
    let l:project_root = ale#Var(a:buffer, 'java_sbtserver_project_root')

    if l:project_root is? ''
        let l:project_root = ale#path#FindNearestFile(a:buffer, 'build.sbt')

        return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
    endif

    return l:project_root
endfunction

function! ale_linters#java#sbtserver#GetAddress(buffer) abort
    let l:address = ale#Var(a:buffer, 'java_sbtserver_address')

    return l:address
endfunction

call ale#linter#Define('java', {
\   'name': 'sbtserver',
\   'lsp': 'socket',
\   'address': function('ale_linters#java#sbtserver#GetAddress'),
\   'language': 'java',
\   'project_root': function('ale_linters#java#sbtserver#GetProjectRoot'),
\})
