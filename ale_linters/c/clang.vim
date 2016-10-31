" Author: Masahiro H https://github.com/mshr-h
" Description: clang linter for c files

" Set this option to change the Clang options for warnings for C.
if !exists('g:ale_c_clang_options')
    " let g:ale_c_clang_options = '-Wall'
    " let g:ale_c_clang_options = '-std=c99 -Wall'
    " c11 compatible
    let g:ale_c_clang_options = '-std=c11 -Wall'
endif

call ale#linter#Define('c', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': 'clang',
\   'command': 'clang -S -x c -fsyntax-only '
\       . g:ale_c_clang_options
\       . ' -',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
