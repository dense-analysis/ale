" Author: Nicolas Derumigny <https://github.com/nicolasderumigny>
" Description: Slang-server LSP for verilog

call ale#Set('verilog_slang_server_options', '')
call ale#Set('verilog_slang_server_executable', 'slang-server')
call ale#Set('verilog_slang_server_config', {})

function! ale_linters#verilog#slang_server#GetProjectRoot(buffer) abort
    let l:project_dir = ale#path#FindNearestDirectory(a:buffer, '.slang')

    if !empty(l:project_dir)
        return fnamemodify(l:project_dir, ':h:h')
    else
        return fnamemodify('', ':h')
    endif
endfunction

function! ale_linters#verilog#slang_server#GetCommand(buffer) abort
    let l:command = ale#Escape(ale#Var(a:buffer, 'verilog_slang_server_executable'))
    let l:options = ale#Var(a:buffer, 'verilog_slang_server_options')

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    return l:command
endfunction


call ale#linter#Define('verilog', {
\   'name': 'slang_server',
\   'lsp': 'stdio',
\   'lsp_config': {b -> ale#Var(b, 'verilog_slang_server_config')},
\   'executable': {b -> ale#Var(b, 'verilog_slang_server_executable')},
\   'command': function('ale_linters#verilog#slang_server#GetCommand') ,
\   'project_root': function('ale_linters#verilog#slang_server#GetProjectRoot'),
\})
