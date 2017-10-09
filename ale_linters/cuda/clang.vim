" Author: blahgeek <i@blahgeek.com>
" Description: Clang linter for cuda files
"
" Almost same as clang linter for cpp

call ale#Set('cuda_clang_executable', 'clang++')
call ale#Set('cuda_clang_options', '-std=c++14 -Wall')

function! ale_linters#cuda#clang#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cuda_clang_executable')
endfunction

function! ale_linters#cuda#clang#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#cuda#clang#GetExecutable(a:buffer))
    \   . ' -S -x cuda -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'cuda_clang_options') . ' -'
endfunction

call ale#linter#Define('cuda', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#cuda#clang#GetExecutable',
\   'command_callback': 'ale_linters#cuda#clang#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
