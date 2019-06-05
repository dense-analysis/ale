" Author: Horacio Sanson <https://github.com/hsanson>
" Description: Support for the Java language server https://github.com/georgewfraser/vscode-javac

call ale#Set('java_javalsp_executable', '')
call ale#Set('java_javalsp_external_deps', [])
call ale#Set('java_javalsp_classpaths', [])

function! ale_linters#java#javalsp#Executable(buffer) abort
    return ale#Var(a:buffer, 'java_javalsp_executable')
endfunction

function! ale_linters#java#javalsp#Deps(buffer) abort
    let l:deps = ale#Var(a:buffer, 'java_javalsp_external_deps')

    return type(l:deps) is v:t_list
    \ ? l:deps
    \ : function(l:deps)(a:buffer)
endfunction

function! ale_linters#java#javalsp#Paths(buffer) abort
    let l:paths = ale#Var(a:buffer, 'java_javalsp_classpaths')

    return type(l:paths) is v:t_list
    \ ? l:paths
    \ : function(l:paths)(a:buffer)
endfunction

function! ale_linters#java#javalsp#Options(buffer) abort
    return {
    \ 'java': {
    \    'externalDependencies': ale_linters#java#javalsp#Deps(a:buffer),
    \    'classPath': ale_linters#java#javalsp#Paths(a:buffer)
    \ }
    \}
endfunction

function! ale_linters#java#javalsp#Command(buffer) abort
    let l:executable = ale_linters#java#javalsp#Executable(a:buffer)

    if fnamemodify(l:executable, ':t') is# 'java'
        " For backward compatibility.
        let l:cmd = [
        \ ale#Escape(l:executable),
        \ '--add-exports jdk.compiler/com.sun.tools.javac.api=javacs',
        \ '--add-exports jdk.compiler/com.sun.tools.javac.code=javacs',
        \ '--add-exports jdk.compiler/com.sun.tools.javac.comp=javacs',
        \ '--add-exports jdk.compiler/com.sun.tools.javac.main=javacs',
        \ '--add-exports jdk.compiler/com.sun.tools.javac.tree=javacs',
        \ '--add-exports jdk.compiler/com.sun.tools.javac.model=javacs',
        \ '--add-exports jdk.compiler/com.sun.tools.javac.util=javacs',
        \ '--add-opens jdk.compiler/com.sun.tools.javac.api=javacs',
        \ '-m javacs/org.javacs.Main',
        \]

        return join(l:cmd, ' ')
    else
        return ale#Escape(l:executable)
    endif
endfunction

call ale#linter#Define('java', {
\   'name': 'javalsp',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#java#javalsp#Executable'),
\   'command': function('ale_linters#java#javalsp#Command'),
\   'language': 'java',
\   'project_root': function('ale#java#FindProjectRoot'),
\   'lsp_config': function('ale_linters#java#javalsp#Options')
\})
