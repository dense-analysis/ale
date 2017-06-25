" Author: Masahiro H https://github.com/mshr-h
" Description: clang linter for c files

" Set this option to change the Clang options for warnings for C.
if !exists('g:ale_c_clang_options')
    " let g:ale_c_clang_options = '-Wall'
    " let g:ale_c_clang_options = '-std=c99 -Wall'
    " c11 compatible
    let g:ale_c_clang_options = '-std=c11 -Wall'
endif

function! ale_linters#c#clang#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return 'clang -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'c_clang_options') . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': 'clang',
\   'command_callback': 'ale_linters#c#clang#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
