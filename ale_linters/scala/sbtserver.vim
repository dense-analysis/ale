" Author: ophirr33 <coghlan.ty@gmail.com>
" Description: TCP lsp client for sbt Server

call ale#Set('scala_sbtserver_address', '')
call ale#Set('scala_sbtserver_project_root', '')

function! ale_linters#scala#sbtserver#GetProjectRoot(buffer) abort
    let l:project_root = ale#Var(a:buffer, 'scala_sbtserver_project_root')
    if l:project_root is? ''
        let l:project_root = ale#path#FindNearestFile(a:buffer, 'build.sbt')
        return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
    endif
    return l:project_root
endfunction

function! ale_linters#scala#sbtserver#GetAddress(buffer) abort
    let l:address = ale#Var(a:buffer, 'scala_sbtserver_address')
    if l:address is? ''
        let l:project_root = ale_linters#scala#sbtserver#GetProjectRoot(a:buffer)
        let l:active_file = l:project_root . '/project/target/active.json'
        if !empty(glob(l:active_file))
            let l:active = json_decode(join(readfile(l:project_root . '/project/target/active.json')))
            if has_key(l:active, 'uri')
                return substitute(l:active.uri, 'tcp://', '', '')
            endif
        endif
    endif
    return l:address
endfunction

call ale#linter#Define('scala', {
\   'name': 'sbtserver',
\   'lsp': 'socket',
\   'address_callback': 'ale_linters#scala#sbtserver#GetAddress',
\   'language': 'scala',
\   'project_root_callback': 'ale_linters#scala#sbtserver#GetProjectRoot',
\})
