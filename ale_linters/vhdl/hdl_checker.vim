" Author:      suoto <andre820@gmail.com>
" Description: Adds support for HDL Code Checker, which wraps vcom/vlog, ghdl
"              or xvhdl. More info on https://github.com/suoto/hdl_checker

let s:default_config_file = has('unix') ? '.hdl_checker.config' : '_hdl_checker.config'
let s:hdl_checker_executable = 'hdl_checker'

call ale#Set('hdl_checker_config_file', s:default_config_file)
call ale#Set('hdl_checker_extra_args', v:null)

function! s:GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, s:default_config_file)
    let l:mods = ':h'

    " Search for .git to use as root
    if empty(l:project_root)
        let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')
        let l:mods = ':h:h'
    endif

    return !empty(l:project_root) ? fnamemodify(l:project_root, l:mods) : ''

endfunction

function! s:getLspCommand(buffer) abort
  let l:command = [
  \ s:hdl_checker_executable,
  \ '--lsp']

  " Add extra parameters only if config has been set

  let l:extra_args = ale#Var(a:buffer, 'hdl_checker_extra_args')

  if l:extra_args != v:null
    let l:command += [l:extra_args]
  endif

  return join(l:command, ' ')

endfunction

" HDL Checker works for VHDL, Verilog and SystemVerilog, add
for s:filetype in ['vhdl', 'verilog', 'systemverilog']
  call ale#linter#Define(s:filetype, {
  \ 'name': 'hdl_checker',
  \ 'lsp': 'stdio',
  \ 'language': s:filetype,
  \ 'executable': s:hdl_checker_executable,
  \ 'command': function('s:getLspCommand'),
  \ 'project_root': function('s:GetProjectRoot'),
  \ 'initialization_options': {b -> {'project_file': ale#Var(b, 'hdl_checker_config_file')}},
  \ })
endfor

