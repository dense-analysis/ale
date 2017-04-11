" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>
" Description: clang-tidy linter for cpp files

" Set this option to change the clang-tidy options for warnings for C.
let g:ale_cpp_clangtidy_options =
\   get(g:, 'ale_cpp_clangtidy_options', '-std=c++14 -Wall')

function! ale_linters#cpp#clangtidy#GetCommand(buffer) abort
    return 'clang-tidy %t -- ' . g:ale_cpp_clangtidy_options
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable': 'clang-tidy',
\   'command_callback': 'ale_linters#cpp#clangtidy#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
