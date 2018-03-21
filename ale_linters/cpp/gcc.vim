" Author: geam <mdelage@student.42.fr>
" Description: gcc linter for cpp files
"
call ale#Set('cpp_gcc_executable', 'gcc')
call ale#Set('cpp_gcc_options', '-std=c++14 -Wall')

function! ale_linters#cpp#gcc#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_gcc_executable')
endfunction

function! ale_linters#cpp#gcc#GetCommand(buffer) abort
    " attempt to get args from compilation database
    let l:args = ale#c#FindCompileArgs(a:buffer)

    " if we've found compile args then just use those
    if has_key(l:args, 'args') && has_key(l:args, 'directory')
        return 'cd ' . l:args.directory . ' && '
        \   . 'gcc -S -x c++ -fsyntax-only '
        \   . l:args.args
        \   . ' -'
    endif

    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#cpp#gcc#GetExecutable(a:buffer))
    \   . ' -S -x c++ -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'cpp_gcc_options') . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'g++',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#cpp#gcc#GetExecutable',
\   'command_callback': 'ale_linters#cpp#gcc#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
