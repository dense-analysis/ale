" Author: geam <mdelage@student.42.fr>
" Description: gcc linter for cpp files

" Set this option to change the GCC options for warnings for C.
if !exists('g:ale_cpp_gcc_options')
  " added c++14 standard support
  " POSIX thread and standard c++ thread and atomic library Linker
  " let g:ale_cpp_gcc_options = '-std=c++1z' for c++17
  " for previous version and default, you can just use
  " let g:ale_cpp_gcc_options = '-Wall'
  " for more see man pages of gcc
  " $ man g++
  " make sure g++ in your $PATH
  " Add flags according to your requirements
    let g:ale_cpp_gcc_options = '-std=c++14 -Wall'
endif

function! ale_linters#cpp#gcc#GetCommand(buffer) abort
    return 'gcc -S -x c++ -fsyntax-only '
    \      . g:ale_cpp_gcc_options . ' -'

endfunction

call ale#linter#Define('cpp', {
\   'name': 'g++',
\   'output_stream': 'stderr',
\   'executable': 'g++',
\   'command_callback': 'ale_linters#cpp#gcc#GetCommand',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
