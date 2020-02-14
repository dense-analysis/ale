" Author: Dan Loman <https://github.com/namolnad>
" Description: Support for sourcekit-lsp https://github.com/apple/sourcekit-lsp

let s:default_executable = 'sourcekit-lsp'

call ale#Set('sourcekit_lsp_executable', s:default_executable)
call ale#Set('swift_sourcekit_lsp_executable', s:default_executable)

function! ale_linters#swift#sourcekitlsp#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'sourcekit_lsp_executable') isnot# s:default_executable
        execute 'echom ''sourcekit_lsp_executable is deprecated. Use `let swift_sourcekitlsp_executable instead`'''

        return ale#Var(a:buffer, 'sourcekit_lsp_executable')
    endif

    return ale#Var(a:buffer, 'swift_sourcekit_lsp_executable')
endfunction

call ale#linter#Define('swift', {
\   'name': 'sourcekitlsp',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#swift#sourcekitlsp#GetExecutable'),
\   'command': '%e',
\   'project_root': function('ale#swift#FindProjectRoot'),
\   'language': 'swift',
\})
