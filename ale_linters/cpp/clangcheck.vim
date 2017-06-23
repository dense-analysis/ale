" Author: gagbo <gagbobada@gmail.com>
" Description: clang-check linter for cpp files

" Set this option to manually set some options for clang-check.
let g:ale_cpp_clang_check_options = get(g:, 'ale_cpp_clang_check_options', '')

function! ale_linters#cpp#clangcheck#GetCommand(buffer) abort
    let l:user_options = ale#Var(a:buffer, 'cpp_clang_check_options')
    let l:extra_options = !empty(l:user_options)
    \   ? l:user_options
    \   : ''

    return 'clang-check ' . '%s' . l:extra_options
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangcheck',
\   'output_stream': 'stdout',
\   'executable': 'clang-check',
\   'command_callback': 'ale_linters#cpp#clangcheck#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
