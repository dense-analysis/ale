" Author: Dan Loman <https://github.com/namolnad>
" Description: Support for sourcekit-lsp https://github.com/apple/sourcekit-lsp

call ale#Set('sourcekit_lsp_executable', 'sourcekit-lsp')

function! ale_linters#swift#sourcekitlsp#Command(buffer) abort
    return ale#Var(a:buffer, 'sourcekit_lsp_executable')
endfunction

function! ale_linters#swift#sourcekitlsp#Executable(buffer)
    return ale#Var(a:buffer, 'sourcekit_lsp_executable')
endfunction

call ale#linter#Define('swift', {
\   'name': 'sourcekitlsp',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#swift#sourcekitlsp#Executable',
\   'command_callback': 'ale_linters#swift#sourcekitlsp#Command',
\   'project_root_callback': 'ale#swift#FindProjectRoot',
\   'language': 'swift',
\})
