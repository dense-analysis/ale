" Author: Ye Jingchen <ye.jingchen@gmail.com>, Ben Falconer <ben@falconers.me.uk>, jtalowell <jtalowell@protonmail.com>
" Description: A language server for C

call ale#Set('c_ccls_executable', 'ccls')
call ale#Set('c_ccls_init_options', {})
call ale#Set('c_build_dir', '')

function! ale_linters#c#ccls#GetOptions(buffer) abort
    let l:options = copy(ale#Var(a:buffer, 'c_ccls_init_options'))

    " Set the compile_commands directory by default, if one is not provided.
    if !has_key(l:options, 'compilationDatabaseDirectory')
        let l:dir = ale#c#GetBuildDirectory(a:buffer)

        if !empty(l:dir)
            let l:options.compilationDatabaseDirectory = l:dir
        endif
    endif

    return l:options
endfunction

call ale#linter#Define('c', {
\   'name': 'ccls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'c_ccls_executable')},
\   'command': '%e',
\   'project_root': function('ale#handlers#ccls#GetProjectRoot'),
\   'initialization_options': function('ale_linters#c#ccls#GetOptions'),
\})
