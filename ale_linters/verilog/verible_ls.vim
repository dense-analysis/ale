" Author: Nicolas Derumigny <https://github.com/nicolasderumigny>
" Description: Verible LSP for verilog

call ale#Set('verilog_verible_ls_options', '--rules_config_search')
call ale#Set('verilog_verible_ls_rules', '')
call ale#Set('verilog_verible_ls_executable', 'verible-verilog-ls')
call ale#Set('verilog_verible_ls_config', {})

function! ale_linters#verilog#verible_ls#GetProjectRoot(buffer) abort
    let l:git_dir = ale#path#FindNearestFile(a:buffer, 'verible.filelist')

    if !empty(l:git_dir)
        return fnamemodify(l:git_dir, ':p:h')
    else
        return fnamemodify('', ':h')
    endif
endfunction

function! ale_linters#verilog#verible_ls#GetCommand(buffer) abort
    let l:command = ale#Escape(ale#Var(a:buffer, 'verilog_verible_ls_executable'))
    let l:options = ale#Var(a:buffer, 'verilog_verible_ls_options')
    let l:rules = ale#Var(a:buffer, 'verilog_verible_ls_rules')

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    if l:rules isnot# ''
        let l:command .= ' --rules=' . l:rules
    endif

    return l:command
endfunction


call ale#linter#Define('verilog', {
\   'name': 'verible_ls',
\   'lsp': 'stdio',
\   'lsp_config': {b -> ale#Var(b, 'verilog_verible_ls_config')},
\   'executable': {b -> ale#Var(b, 'verilog_verible_ls_executable')},
\   'command': function('ale_linters#verilog#verible_ls#GetCommand') ,
\   'project_root': function('ale_linters#verilog#verible_ls#GetProjectRoot'),
\})
