" Author: Masahiro H https://github.com/mshr-h
" Description: clang linter for c files

call ale#Set('c_clang_executable', 'clang')
call ale#Set('c_clang_options', '-std=c11 -Wall')

function! ale_linters#c#clang#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_clang_executable')
endfunction

function! ale_linters#c#clang#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#c#clang#GetExecutable(a:buffer))
    \   . ' -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'c_clang_options') . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#c#clang#GetExecutable',
\   'command_callback': 'ale_linters#c#clang#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
