" Author: Ben Boeckel <github@me.benboeckel.net>
" Description: A CLI tool for code structural search, lint and rewriting

call ale#Set('astgrep_executable', 'ast-grep')

function! ale#handlers#astgrep#GetCommand(buffer) abort
    return '%e lsp'
endfunction

function! ale#handlers#astgrep#GetProjectRoot(buffer) abort
    " Try to find nearest sgconfig.yml
    let l:sgconfig_file = ale#path#FindNearestFile(a:buffer, 'sgconfig.yml')

    if !empty(l:sgconfig_file)
        return fnamemodify(l:sgconfig_file . '/', ':p:h:h')
    endif

    return ''
endfunction

function! ale#handlers#astgrep#Define(lang) abort
    call ale#linter#Define(a:lang, {
    \   'name': 'astgrep',
    \   'lsp': 'stdio',
    \   'executable': {b -> ale#Var(b, 'astgrep_executable')},
    \   'command': function('ale#handlers#astgrep#GetCommand'),
    \   'project_root': function('ale#handlers#astgrep#GetProjectRoot'),
    \})
endfunction
