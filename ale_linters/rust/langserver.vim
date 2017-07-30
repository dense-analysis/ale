" Author: w0rp <devw0rp@gmail.com>
" Description: A language server for Rust

call ale#Set('rust_langserver_executable', 'rls')

function! ale_linters#rust#langserver#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'rust_langserver_executable')
endfunction

function! ale_linters#rust#langserver#GetCommand(buffer) abort
    let l:executable = ale_linters#rust#langserver#GetExecutable(a:buffer)

    return ale#Escape(l:executable) . ' +nightly'
endfunction

function! ale_linters#rust#langserver#GetLanguage(buffer) abort
    return 'rust'
endfunction

function! ale_linters#rust#langserver#GetProjectRoot(buffer) abort
    let l:cargo_file = ale#path#FindNearestFile(a:buffer, 'Cargo.toml')

    return !empty(l:cargo_file) ? fnamemodify(l:cargo_file, ':h') : ''
endfunction

call ale#linter#Define('rust', {
\   'name': 'langserver',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#rust#langserver#GetExecutable',
\   'command_callback': 'ale_linters#rust#langserver#GetCommand',
\   'language_callback': 'ale_linters#rust#langserver#GetLanguage',
\   'project_root_callback': 'ale_linters#rust#langserver#GetProjectRoot',
\})
