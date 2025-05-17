" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: A CLI tool for code structural search, lint and rewriting

call ale#Set('astgrep_executable', 'ast-grep')

function! ale_linters#generic#astgrep#GetCommand(buffer) abort
    return '%e lsp'
endfunction

function! ale_linters#generic#astgrep#GetProjectRoot(buffer) abort
    " Try to find nearest sgconfig.yml
    let l:sgconfig_file = ale#path#FindNearestFile(a:buffer, 'sgconfig.yml')

    if !empty(l:sgconfig_file)
        return fnamemodify(l:sgconfig_file, ':h')
    endif

    return ''
endfunction

call ale#linter#Define('generic', {
\   'name': 'astgrep',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'astgrep_executable')},
\   'command': function('ale_linters#generic#astgrep#GetCommand'),
\   'project_root': function('ale_linters#generic#astgrep#GetProjectRoot'),
\})
