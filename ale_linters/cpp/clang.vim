" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Description: clang linter for cpp files

" Set this option to change the Clang options for warnings for CPP.
if !exists('g:ale_cpp_clang_options')
    let g:ale_cpp_clang_options = '-std=c++14 -Wall'
endif

call ale#linter#Define('cpp', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': 'clang++',
\   'command': 'clang++ -S -x c++ -fsyntax-only '
\       . g:ale_cpp_clang_options
\       . ' -',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
