" Author: Sven-Hendrik Haase <svenstaro@gmail.com>
" Description: glslls-based linter for glsl files

let g:ale_glsl_glslls_executable =
\ get(g:, 'ale_glsl_glslls_executable', '/home/svenstaro/prj/glsl-language-server/build/glslls')

let g:ale_glsl_glslls_options = get(g:, 'ale_glsl_glslls_options', '-l /tmp/glslls.log')

function! ale_linters#glsl#glslls#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'glsl_glslls_executable')
endfunction

function! ale_linters#glsl#glslls#GetCommand(buffer) abort
    return ale_linters#glsl#glslls#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'glsl_glslls_options')
    \   . ' ' . '--stdin'
endfunction

function! ale_linters#glsl#glslls#GetLanguage(buffer) abort
    return 'glsl'
endfunction

function! ale_linters#glsl#glslls#GetProjectRoot(buffer) abort
    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    return !empty(l:git_path) ? fnamemodify(l:git_path, ':h:h') : ''
endfunction

call ale#linter#Define('glsl', {
\   'name': 'glslls',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#glsl#glslls#GetExecutable',
\   'command_callback': 'ale_linters#glsl#glslls#GetCommand',
\   'language_callback': 'ale_linters#glsl#glslls#GetLanguage',
\   'project_root_callback': 'ale_linters#glsl#glslls#GetProjectRoot',
\})
