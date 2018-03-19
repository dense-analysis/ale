" Author: w0rp <devw0rp@gmail.com>
" Description: gcc linter for c files

call ale#Set('c_gcc_executable', 'gcc')
call ale#Set('c_gcc_options', '-std=c11 -Wall')
call ale#Set('c_parse_makefile', 0)

function! ale_linters#c#gcc#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_gcc_executable')
endfunction

function! ale_linters#c#gcc#GetCommand(buffer) abort
    let l:cflags = []
    if g:ale_c_parse_makefile
        let l:cflags = join(ale#c#ParseMakefile(a:buffer), ' ')
    endif
    if empty(l:cflags)
        let l:cflags = ale#c#IncludeOptions(ale#c#FindLocalHeaderPaths(a:buffer))
    endif

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#c#gcc#GetExecutable(a:buffer))
    \   . ' -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . l:cflags . ' '
    \   . ale#Var(a:buffer, 'c_gcc_options') . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'gcc',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#c#gcc#GetExecutable',
\   'command_callback': 'ale_linters#c#gcc#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
