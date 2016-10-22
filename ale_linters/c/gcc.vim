" Author: w0rp <devw0rp@gmail.com>
" Description: gcc linter for c files

" Set this option to change the GCC options for warnings for C.
if !exists('g:ale_c_gcc_options')
    " let g:ale_c_gcc_options = '-Wall'
    " let g:ale_c_gcc_options = '-std=c99 -Wall'
    " c11 compatible
    let g:ale_c_gcc_options = '-std=c11 -Wall'
endif

call ale#linter#Define('c', {
\   'name': 'gcc',
\   'output_stream': 'stderr',
\   'executable': 'gcc',
\   'command': 'gcc -S -x c -fsyntax-only '
\       . g:ale_c_gcc_options
\       . ' -',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
