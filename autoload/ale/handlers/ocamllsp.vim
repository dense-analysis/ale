" Author: Risto Stevcev <me@risto.codes>
" Description: Handlers for the official OCaml language server

let s:ocamllsp = 'ocamllsp'

function! s:OnGetExecutable(buffer, output, meta) abort
    if a:meta.exit_code == 0
        return a:output[0]
    endif
endfunction

function! ale#handlers#ocamllsp#GetExecutable(buffer) abort
    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:ocamllsp_use_opam = ale#Var(a:buffer, l:filetype . '_ocamllsp_use_opam')
    let l:ocamllsp_use_esy = ale#Var(a:buffer, l:filetype . '_ocamllsp_use_esy')

    if l:ocamllsp_use_opam
        let l:check_cmd = 'opam config exec -- which ' . s:ocamllsp

        return ale#command#Run(a:buffer, l:check_cmd, function('s:OnGetExecutable'))
    elseif l:ocamllsp_use_esy
        let l:check_cmd =  'esy exec-command --include-build-env -- which '. s:ocamllsp

        return ale#command#Run(a:buffer, l:check_cmd, function('s:OnGetExecutable'))
    else
        return s:ocamllsp
    endif
endfunction

function! ale#handlers#ocamllsp#GetCommand(buffer) abort
    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:ocamllsp_use_opam = ale#Var(a:buffer, l:filetype . '_ocamllsp_use_opam')
    let l:ocamllsp_use_esy = ale#Var(a:buffer, l:filetype . '_ocamllsp_use_esy')

    if l:ocamllsp_use_opam
        return 'opam config exec -- ' . s:ocamllsp
    elseif l:ocamllsp_use_esy
        return 'esy exec-command --include-build-env -- ' . s:ocamllsp
    else
        return s:ocamllsp
    endif
endfunction

function! ale#handlers#ocamllsp#GetLanguage(buffer) abort
    return getbufvar(a:buffer, '&filetype')
endfunction

function! ale#handlers#ocamllsp#GetProjectRoot(buffer) abort
    let l:dune_project_file = ale#path#FindNearestFile(a:buffer, 'dune-project')

    return !empty(l:dune_project_file) ? fnamemodify(l:dune_project_file, ':h') : ''
endfunction
