" Author: gagbo <gagbobada@gmail.com>, w0rp <devw0rp@gmail.com>, roel0 <postelmansroel@gmail.com>
" Description: Functions for integrating with C-family linters.

call ale#Set('c_parse_makefile', 0)
let s:sep = has('win32') ? '\' : '/'

function! ale#c#FindProjectRoot(buffer) abort
    for l:project_filename in ['.git/HEAD', 'configure', 'Makefile', 'CMakeLists.txt']
        let l:full_path = ale#path#FindNearestFile(a:buffer, l:project_filename)

        if !empty(l:full_path)
            let l:path = fnamemodify(l:full_path, ':h')

            " Correct .git path detection.
            if fnamemodify(l:path, ':t') is# '.git'
                let l:path = fnamemodify(l:path, ':h')
            endif

            return l:path
        endif
    endfor

    return ''
endfunction

function! ale#c#ParseCFlagsToList(buffer, cflags) abort
    let l:project_root = ale#c#FindProjectRoot(a:buffer)
    let l:previous_option = ''
    let l:shell_option = 0
    let l:macro_option = 0
    let l:cflags_list = []

    for l:option in a:cflags
        " Check if cflag contained spaces
        if l:shell_option || stridx(l:option, '=`') >= 0
            " Cflag contained shell command with spaces (ex. -D='date +%s')
            let l:shell_option = 1
            let l:previous_option .= l:option
            if l:option[-1: -1] isnot? '`'
                let l:previous_option .= ' '
                continue
            endif
            let l:shell_option = 0
        elseif l:macro_option || stridx(l:option, '$((') > 0
            " Cflag contained macro with spaces (ex -Da=$(( 4 * 20  )))
            let l:macro_option = 1
            let l:previous_option .= l:option
            if stridx(l:option, '))') < 0
                let l:previous_option .= ' '
                continue
            endif
            let l:macro_option = 0
        endif
        if l:previous_option isnot? ''
            let l:option = l:previous_option
            let l:previous_option = ''
        endif
        " Fix relative paths if needed
        if stridx(l:option, '-I') >= 0
            if stridx(l:option, '-I' . s:sep) < 0
                let l:option = '-I' . l:project_root . s:sep . l:option[2:]
            endif
        endif
        " Parse the cflag
        if stridx(l:option, '-I') >= 0 ||
           \ stridx(l:option, '-D') >= 0
            if index(l:cflags_list, l:option) < 0
                call add(l:cflags_list, l:option)
            endif
        endif
    endfor
    return l:cflags_list
endfunction

function! ale#c#ParseCFlags(buffer, stdout_make) abort
    if g:ale_c_parse_makefile
        for l:cflags in split(a:stdout_make, '\n')
            if stridx(l:cflags, expand('#' . a:buffer . '...'))
                let l:cflags = split(l:cflags)
                break
            endif
        endfor
        if !empty(l:cflags)
            return ale#c#ParseCFlagsToList(a:buffer, l:cflags)
       endif
    endif
    retur []
endfunction

function! ale#c#ParseMakefile(buffer) abort
    if g:ale_c_parse_makefile
        let l:project_root = ale#c#FindProjectRoot(a:buffer)
        let l:project_cflags = []

        if !empty(l:project_root)
            if !empty(globpath(l:project_root, 'Makefile', 0))
                return 'cd '. l:project_root . ' && make -n'
            endif
        endif
    endif
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
        return [ale#path#Simplify(l:project_root . s:sep . 'include')]
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
            let l:c_build_dir = l:path . s:sep . l:dirname

            if filereadable(l:c_build_dir . '/compile_commands.json')
                return l:c_build_dir
            endif
        endfor
    endfor

    return ''
endfunction
