" Author: Nicolas Derumigny <https://github.com/nicolasderumigny>
" Description: Verible LSP for verilog

function! ale_linters#verilog#verible_ls#GetProjectRoot(buffer) abort
    let l:git_dir = ale#path#FindNearestFile(a:buffer, 'verible.filelist')

    if !empty(l:git_dir)
        return fnamemodify(l:git_dir, ':p:h')
    else
        return fnamemodify('', ':h')
    endif
endfunction

call ale#Set('verilog_verible_ls_executable', 'verible-verilog-ls')
call ale#Set('verilog_verible_ls_config', {})

call ale#linter#Define('verilog', {
\   'name': 'verible_ls',
\   'lsp': 'stdio',
\   'lsp_config': {b -> ale#Var(b, 'verilog_verible_ls_config')},
\   'executable': {b -> ale#Var(b, 'verilog_verible_ls_executable')},
\   'command': '%e',
\   'project_root': function('ale_linters#verilog#verible_ls#GetProjectRoot'),
\})
