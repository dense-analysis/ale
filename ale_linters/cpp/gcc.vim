" Author: geam <mdelage@student.42.fr>
" Description: gcc linter for cpp files

if exists('g:loaded_ale_linters_cpp_gcc')
    finish
endif

let g:loaded_ale_linters_cpp_gcc = 1

" Set this option to change the GCC options for warnings for C.
if !exists('g:ale_cpp_gcc_options')
    let g:ale_cpp_gcc_options = '-Wall'
endif

call ale#linter#Define('cpp', {
\   'name': 'gcc',
\   'output_stream': 'stderr',
\   'executable': 'gcc',
\   'command': 'gcc -S -x c++ -fsyntax-only '
\       . g:ale_cpp_gcc_options
\       . ' -',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
