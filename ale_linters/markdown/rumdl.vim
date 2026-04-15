" Author: Evan Chen <evan@evanchen.cc>
" Description: Fast Markdown linter and formatter written in Rust


call ale#Set('markdown_rumdl_executable', 'rumdl')
call ale#Set('markdown_rumdl_options', '')

function! ale_linters#markdown#rumdl#GetProjectRoot(buffer) abort
    let l:dotconfig = ale#path#FindNearestFile(a:buffer, '.rumdl.toml')
    let l:config = ale#path#FindNearestFile(a:buffer, 'rumdl.toml')

    if !empty(l:dotconfig) && !empty(l:config)
        let l:nearest = len(l:dotconfig) >= len(l:config) ? l:dotconfig : l:config

        return fnamemodify(l:nearest, ':h')
    elseif !empty(l:dotconfig)
        return fnamemodify(l:dotconfig, ':h')
    elseif !empty(l:config)
        return fnamemodify(l:config, ':h')
    endif

    " Try to find nearest pyproject.toml
    let l:pyproject_file = ale#path#FindNearestFile(a:buffer, 'pyproject.toml')

    if !empty(l:pyproject_file)
        return fnamemodify(l:pyproject_file . '/', ':p:h:h')
    endif

    " Try to find nearest `git` directory
    let l:gitdir = ale#path#FindNearestFile(a:buffer, '.git')

    if !empty(l:gitdir)
        return fnamemodify(l:gitdir . '/', ':p:h:h')
    endif

    return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

call ale#linter#Define('markdown', {
\   'name': 'rumdl',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'markdown_rumdl_executable')},
\   'command': {b -> ale#Escape(ale#Var(b, 'markdown_rumdl_executable'))
\       . ' server --stdio'
\       . ale#Pad(ale#Var(b, 'markdown_rumdl_options'))},
\   'project_root': function('ale_linters#markdown#rumdl#GetProjectRoot'),
\   'language': 'markdown',
\})
