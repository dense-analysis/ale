" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Description: clang linter for cpp files

" Set this option to change the Clang options for warnings for CPP.
if !exists('g:ale_cpp_clang_options')
    let g:ale_cpp_clang_options = '-std=c++14 -Wall'
endif

function! ale_linters#cpp#clang#GetCommand(buffer) abort
    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return 'clang++ -S -x c++ -fsyntax-only '
    \   . '-iquote ' . fnameescape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ' ' . g:ale_cpp_clang_options . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': 'clang++',
\   'command_callback': 'ale_linters#cpp#clang#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
