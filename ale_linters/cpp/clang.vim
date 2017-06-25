" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Description: clang linter for cpp files

" Set this option to change the Clang options for warnings for CPP.
if !exists('g:ale_cpp_clang_options')
    let g:ale_cpp_clang_options = '-std=c++14 -Wall'
endif

function! ale_linters#cpp#clang#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return 'clang++ -S -x c++ -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'cpp_clang_options') . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': 'clang++',
\   'command_callback': 'ale_linters#cpp#clang#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
