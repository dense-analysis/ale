" Author: Sven-Hendrik Haase <svenstaro@gmail.com>
" Description: A language server for glsl

call ale#Set('glsl_glslls_executable', 'glslls')

function! ale_linters#glsl#glslls#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'glsl_glslls_executable')
endfunction

function! ale_linters#glsl#glslls#GetCommand(buffer) abort
    let l:executable = ale_linters#glsl#glslls#GetExecutable(a:buffer)

    return ale#Escape(l:executable) . ' -l ' . tempname() . ' --stdin --verbose'
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
