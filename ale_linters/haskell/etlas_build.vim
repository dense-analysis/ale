" Author: Paolo Gavocanov, based on stack_build from Jake Zimmerman <jake@zimmerman.io>
" Description: Like stack-build but for ETA projects
"
" Note: Ideally, this would *only* typecheck. Right now, it also does codegen.

call ale#Set('haskell_etlas_build_options', '')

function! ale_linters#haskell#etlas_build#GetCommand(buffer) abort
    let l:flags = ale#Var(a:buffer, 'haskell_etlas_build_options')

    return 'etlas build ' . l:flags
endfunction

call ale#linter#Define('haskell', {
\   'name': 'etlas-build',
\   'output_stream': 'stderr',
\   'executable': 'etlas',
\   'command_callback': 'ale_linters#haskell#etlas_build#GetCommand',
\   'lint_file': 1,
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})
