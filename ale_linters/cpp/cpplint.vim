" Author: Dawid Kurek https://github.com/dawikur
" Description: cpplint for cpp files

if !exists('g:ale_cpp_cpplint_options')
    let g:ale_cpp_cpplint_options = ''
endif

call ale#linter#Define('cpp', {
\   'name': 'cpplint',
\   'output_stream': 'stderr',
\   'executable': 'cpplint',
\   'command': 'cpplint %s',
\   'callback': 'ale#handlers#cpplint#HandleCppLintFormat',
\   'lint_file': 1,
\})
