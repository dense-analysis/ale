" Author: Ricardo Liang <ricardoliang@gmail.com>
" Description: Texlab language server (Rust rewrite)

call ale#Set('tex_texlab_executable', 'texlab')
call ale#Set('tex_texlab_options', '')

function! ale_linters#tex#texlab#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')

    return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
endfunction

function! ale_linters#tex#texlab#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'tex_texlab_options'))
endfunction

call ale#linter#Define('tex', {
\   'name': 'texlab',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'tex_texlab_executable')},
\   'command': function('ale_linters#tex#texlab#GetCommand'),
\   'project_root': function('ale_linters#tex#texlab#GetProjectRoot'),
\})
