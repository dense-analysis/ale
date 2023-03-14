" Author: Jon Gjengset <jon@thesquareplanet.com>
" Description: The next generation language server for Rust

call ale#Set('rust_analyzer_executable', 'rust-analyzer')
call ale#Set('rust_analyzer_config', {})
call ale#Set('rust_analyzer_use_local_config', 0)

function! ale_linters#rust#analyzer#GetCommand(buffer) abort
    return '%e'
endfunction

function! ale_linters#rust#analyzer#GetProjectRoot(buffer) abort
    " Try to find nearest Cargo.toml for cargo projects
    let l:cargo_file = ale#path#FindNearestFile(a:buffer, 'Cargo.toml')

    if !empty(l:cargo_file)
        return fnamemodify(l:cargo_file, ':h')
    endif

    " Try to find nearest rust-project.json for non-cargo projects
    let l:rust_project = ale#path#FindNearestFile(a:buffer, 'rust-project.json')

    if !empty(l:rust_project)
        return fnamemodify(l:rust_project, ':h')
    endif

    return ''
endfunction

function! ale_linters#rust#analyzer#GetConfig(buffer) abort
    let l:config = copy(ale#Var(a:buffer, 'rust_analyzer_config'))

    if ale#Var(a:buffer, 'rust_analyzer_use_local_config')
        let l:config_local_path = ale#path#FindNearestFile(a:buffer, 'analyzer.json')

        if !empty(l:config_local_path)
            try
                let l:config_local = json_decode(join(readfile(l:config_local_path)))
                let l:config =  extend(l:config, l:config_local)
            catch
            endtry
        endif
    endif

    return l:config
endfunction

call ale#linter#Define('rust', {
\   'name': 'analyzer',
\   'lsp': 'stdio',
\   'initialization_options': function('ale_linters#rust#analyzer#GetConfig'),
\   'executable': {b -> ale#Var(b, 'rust_analyzer_executable')},
\   'command': function('ale_linters#rust#analyzer#GetCommand'),
\   'project_root': function('ale_linters#rust#analyzer#GetProjectRoot'),
\})
