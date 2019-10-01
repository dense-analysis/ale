" Author:      suoto <andre820@gmail.com>
" Description: Adds support for HDL Code Checker, which wraps vcom/vlog, ghdl
"              or xvhdl. More info on https://github.com/suoto/hdl_checker

let s:executable = 'hdl_checker'

call ale#Set('hdl_checker_config_file', has('unix') ? '.hdl_checker.config' : '_hdl_checker.config')
call ale#Set('hdl_checker_extra_args', v:null)

" Can be, in order or preference:
" 1. Nearest config file
" 2. Nearest .git directory
" 3. The current path
function! s:GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, ale#Var(a:buffer, 'hdl_checker_config_file'))
    let l:mods = ':h'

    " Search for .git to use as root
    if empty(l:project_root)
        let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')
        let l:mods = ':h:h'
    endif

    return !empty(l:project_root) ? fnamemodify(l:project_root, l:mods) : expand('#' . a:buffer . ':p:h')
endfunction

function! s:getLspCommand(buffer) abort
    let l:command = s:executable . ' --lsp'

    " Add extra parameters only if config has been set
    let l:extra_args = ale#Var(a:buffer, 'hdl_checker_extra_args')
    if l:extra_args != v:null
        let l:command = l:command . ' ' . l:extra_args
    endif

    return l:command
endfunction

" Setup is identical for VHDL and Verilog/SystemVerilog
for s:language in ['vhdl', 'verilog']
    call ale#linter#Define(s:language, {
    \   'name': 'hdl_checker',
    \   'lsp': 'stdio',
    \   'language': s:language,
    \   'executable': s:executable,
    \   'command': function('s:getLspCommand'),
    \   'project_root': function('s:GetProjectRoot'),
    \   'initialization_options': {b -> {'project_file': ale#Var(b, 'hdl_checker_config_file')}},
    \ })
endfor

