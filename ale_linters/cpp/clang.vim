" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Description: clang linter for cpp files

call ale#Set('cpp_clang_executable', 'clang++')
call ale#Set('cpp_clang_options', '-std=c++14 -Wall')

function! ale_linters#cpp#clang#GetCommand(buffer, output) abort
    let l:cflags = ale#c#GetCFlags(a:buffer, a:output)
    let l:ale_flags = ale#Var(a:buffer, 'cpp_clang_options')

    if l:cflags =~# '-std='
        let l:ale_flags = substitute(
        \   l:ale_flags,
        \   '-std=\(c\|gnu\)++[0-9]\{2\}',
        \   '',
        \   'g')
    endif

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return '%e -S -x c++ -fsyntax-only'
    \   . ' -iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ale#Pad(l:cflags)
    \   . ale#Pad(l:ale_flags) . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': {b -> ale#Var(b, 'cpp_clang_executable')},
\   'command': {b -> ale#c#RunMakeCommand(b, function('ale_linters#cpp#clang#GetCommand'))},
\   'callback': 'ale#handlers#gcc#HandleGCCFormatWithIncludes',
\})
