" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Author: Milan Svoboda <https://github.com/tex>
" Description: clang linter for cpp files

call ale#Set('cpp_clang_executable', 'clang++')
call ale#Set('cpp_clang_options', '-std=c++14 -Wall')

function! ale_linters#cpp#clang#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clang_executable')
endfunction

function! ale_linters#cpp#clang#GetCommand(buffer) abort
    let l:build_dir = ale#c#FindCompileCommands(a:buffer)
    if empty(l:build_dir)
        let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)
        " -iquote with the directory the file is in makes #include work for
        "  headers in the same directory.
        return ale#Escape(ale_linters#cpp#clang#GetExecutable(a:buffer))
        \   . ' -S -x c++ -fsyntax-only '
        \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
        \   . ale#c#IncludeOptions(l:paths)
        \   . ale#Var(a:buffer, 'cpp_clang_options') . ' -'
    else
        let l:c = readfile(l:build_dir . '/compile_commands.json')
        let l:l = json_decode(l:c)
        let l:b = fnamemodify(bufname(a:buffer), ':p')
        for l:d in l:l
            if l:d["file"] == l:b
                " Key 'command' contains -o with path relative to key 'directory'
                " Make it absolute path. This way this linter generates valid
                " .o which makes subsequent build of whole project faster...
                let l:s = substitute(l:d["command"], "-o ", "-o ".l:d["directory"]."/","")
                return l:s
            endif
        endfor
        echom "ALE: Please refresh your compile_commands.json!"
    endif
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#cpp#clang#GetExecutable',
\   'command_callback': 'ale_linters#cpp#clang#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
