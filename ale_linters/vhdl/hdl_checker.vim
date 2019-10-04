" Author:      suoto <andre820@gmail.com>
" Description: Adds support for HDL Code Checker, which wraps vcom/vlog, ghdl
"              or xvhdl. More info on https://github.com/suoto/hdl_checker

call ale#Set('hdl_checker_executable', 'hdl_checker')
call ale#Set('hdl_checker_config_file', has('unix') ? '.hdl_checker.config' : '_hdl_checker.config')
call ale#Set('hdl_checker_options', '')

" Use this as a function so we can mock it on testing. Need to do this because
" test files are inside /testplugin (which refers to the ale repo), which will
" always have a .git folder
function! ale_linters#vhdl#hdl_checker#IsDotGit(path) abort
    return isdirectory(a:path) && ! empty(a:path)
endfunction

" Sould return (in order of preference)
" 1. Nearest config file
" 2. Nearest .git directory
" 3. The current path
function! ale_linters#vhdl#hdl_checker#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(
    \   a:buffer,
    \   ale#Var(a:buffer, 'hdl_checker_config_file'))

    if !empty(l:project_root    )
        return fnamemodify(l:project_root, ':h')
    endif

    " Search for .git to use as root
    let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')

    if ale_linters#vhdl#hdl_checker#IsDotGit(l:project_root)
        return fnamemodify(l:project_root, ':h:h')
    endif

    " As a fallback, use the path of the current buffer
    return expand('#' . a:buffer . ':p:h')
endfunction

function! ale_linters#vhdl#hdl_checker#GetCommand(buffer) abort
    let l:command = ale#Var(a:buffer, 'hdl_checker_executable') . ' --lsp'

    " Add extra parameters only if config has been set
    let l:options = ale#Var(a:buffer, 'hdl_checker_options')

    if ! empty(l:options)
        let l:command = l:command . ' ' . l:options
    endif

    return l:command
endfunction

" To allow testing
function! ale_linters#vhdl#hdl_checker#GetInitOptions(buffer) abort
    return {'project_file': ale#Var(a:buffer, 'hdl_checker_config_file')}
endfunction

" Setup is identical for VHDL and Verilog/SystemVerilog
for s:language in ['vhdl', 'verilog']
    call ale#linter#Define(s:language, {
    \   'name': 'hdl_checker',
    \   'lsp': 'stdio',
    \   'language': s:language,
    \   'executable': { b -> ale#Var(b, 'hdl_checker_executable')},
    \   'command': function('ale_linters#vhdl#hdl_checker#GetCommand'),
    \   'project_root': function('ale_linters#vhdl#hdl_checker#GetProjectRoot'),
    \   'initialization_options': function('ale_linters#vhdl#hdl_checker#GetInitOptions'),
    \ })
endfor

