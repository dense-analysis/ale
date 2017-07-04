" Author: Dawid Kurek https://github.com/dawikur
" Description: cpplint for cpp files

if !exists('g:ale_cpp_cpplint_options')
    let g:ale_cpp_cpplint_options = ''
endif

function! ale_linters#cpp#cpplint#GetCommand(buffer) abort
    return 'cpplint ' . ale#Var(a:buffer, 'cpp_cpplint_options') . ' %s'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'cpplint',
\   'output_stream': 'stderr',
\   'executable': 'cpplint',
\   'command_callback': 'ale_linters#cpp#cpplint#GetCommand',
\   'callback': 'ale#handlers#cpplint#HandleCppLintFormat',
\   'lint_file': 1,
\})
