" Author: Andrey Melentyev <andrey.melentyev@protonmail.com>
" Description: Clangd language server

call ale#Set('cpp_clangd_executable', 'clangd')
call ale#Set('cpp_clangd_options', '')
call ale#Set('c_build_dir', '')

function! ale_linters#cpp#clangd#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'cpp_clangd_options')
    let l:dir_option = ''

    " Set the compile_commands directory by default, if one is not provided.
    if l:options !~# '-compile-commands-dir'
        let l:dir = ale#c#GetBuildDirectory(a:buffer)

        if !empty(l:dir)
            let l:dir_option = '-compile-commands-dir=' . ale#Escape(l:dir)
        endif
    endif

    return '%e' . ale#Pad(l:options) . ale#Pad(l:dir_option)
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangd',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'cpp_clangd_executable')},
\   'command': function('ale_linters#cpp#clangd#GetCommand'),
\   'project_root': function('ale#c#FindProjectRoot'),
\})
