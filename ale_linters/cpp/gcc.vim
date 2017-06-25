" Author: geam <mdelage@student.42.fr>
" Description: gcc linter for cpp files

" Set this option to change the GCC options for warnings for C.
if !exists('g:ale_cpp_gcc_options')
    let s:version = ale#handlers#gcc#ParseGCCVersion(systemlist('gcc --version'))

    if !empty(s:version) && ale#semver#GreaterOrEqual(s:version, [4, 9, 0])
        " Use c++14 support in 4.9 and above.
        let g:ale_cpp_gcc_options = '-std=c++14 -Wall'
    else
        " Use c++1y in older versions.
        let g:ale_cpp_gcc_options = '-std=c++1y -Wall'
    endif

    unlet! s:version
endif

function! ale_linters#cpp#gcc#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return 'gcc -S -x c++ -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'cpp_gcc_options') . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'g++',
\   'output_stream': 'stderr',
\   'executable': 'g++',
\   'command_callback': 'ale_linters#cpp#gcc#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
