" Author: vdeurzen <tim@kompiler.org>
" Description: clang-tidy linter for cpp files

" Set this option to change the clang-tidy options for warnings for C.
if !exists('g:ale_cpp_clangtidy_options')
    let g:ale_cpp_clangtidy_options = '-std=c++14 -Wall'
endif

call ale#linter#Define('cpp', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable': 'clang-tidy',
\   'command': g:ale#util#stdin_wrapper . ' -- ' . g:ale_cpp_clangtidy_options,
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
