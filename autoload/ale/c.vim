" Author: gagbo <gagbobada@gmail.com>, w0rp <devw0rp@gmail.com>
" Description: Functions for integrating with C-family linters.

function! ale#c#FindProjectRoot(buffer) abort
    for l:project_filename in ['.git/HEAD', 'configure', 'Makefile', 'CMakeLists.txt']
        let l:full_path = ale#path#FindNearestFile(a:buffer, l:project_filename)

        if !empty(l:full_path)
            let l:path = fnamemodify(l:full_path, ':h')

            " Correct .git path detection.
            if fnamemodify(l:path, ':t') ==# '.git'
                let l:path = fnamemodify(l:path, ':h')
            endif

            return l:path
        endif
    endfor

    return ''
endfunction

" Given a buffer number, search for a project root, and output a List
" of directories to include based on some heuristics.
"
" For projects with headers in the project root, the project root will
" be returned.
"
" For projects with an 'include' directory, that directory will be returned.
function! ale#c#FindLocalHeaderPaths(buffer) abort
    let l:project_root = ale#c#FindProjectRoot(a:buffer)

    if empty(l:project_root)
        return []
    endif

    " See if we can find .h files directory in the project root.
    " If we can, that's our include directory.
    if !empty(globpath(l:project_root, '*.h', 0))
        return [l:project_root]
    endif

    " Look for .hpp files too.
    if !empty(globpath(l:project_root, '*.hpp', 0))
        return [l:project_root]
    endif

    " If we find an 'include' directory in the project root, then use that.
    if isdirectory(l:project_root . '/include')
        return [simplify(l:project_root . '/include')]
    endif

    return []
endfunction

" Given a List of include paths, create a string containing the -I include
" options for those paths, with the paths escaped for use in the shell.
function! ale#c#IncludeOptions(include_paths) abort
    let l:option_list = []

    for l:path in a:include_paths
        call add(l:option_list, '-I' . ale#Escape(l:path))
    endfor

    if empty(l:option_list)
        return ''
    endif

    return ' ' . join(l:option_list) . ' '
endfunction

let g:ale_c_build_dir_names = get(g:, 'ale_c_build_dir_names', [
\   'build',
\   'bin',
\])

" Given a buffer number, find the build subdirectory with compile commands
" The subdirectory is returned without the trailing /
function! ale#c#FindCompileCommands(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        for l:dirname in ale#Var(a:buffer, 'c_build_dir_names')
            let l:c_build_dir = l:path . '/' . l:dirname

            if filereadable(l:c_build_dir . '/compile_commands.json')
                return l:c_build_dir
            endif
        endfor
    endfor

    return ''
endfunction

" Given a buffer number, find a compilation database (compile_commands.json)
" and parse this into an argument string
function! ale#c#FindCompileArgs(buffer) abort
    let l:compile_args = {}

    let l:compile_commands_path = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')
    if !empty(l:compile_commands_path)
        let l:bufname = fnamemodify(bufname(a:buffer), ':p')

        for elem in json_decode(readfile(l:compile_commands_path))
            if elem["file"] == l:bufname
                let l:compile_args["directory"] = elem["directory"]
                " skip unwanted stuff
                "   first arg (compiler)
                "   last arg (filename)
                "    -o objectfile
                "    -c
                let l_skip = 0
                let l:args = []
                for arg in split(elem["command"], ' ')[2:-2]
                    if (l_skip == 1)
                        let l_skip = 0
                    elseif (arg == '-o')
                        " skip next 1 arg as well
                        let l_skip = 1
                    elseif (arg == '-c')
                        " simply omit
                    else
                        let l:args += [arg]
                    endif
                endfor

                let l:compile_args["args"] = join(l:args, ' ')

                break
            endif
        endfor
    endif

    return l:compile_args
endfunction
