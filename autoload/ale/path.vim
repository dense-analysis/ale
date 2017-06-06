" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with paths in the filesystem.

" Given a buffer and a filename, find the nearest file by searching upwards
" through the paths relative to the given buffer.
function! ale#path#FindNearestFile(buffer, filename) abort
    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p')

    let l:relative_path = findfile(a:filename, l:buffer_filename . ';')

    if !empty(l:relative_path)
        return fnamemodify(l:relative_path, ':p')
    endif

    return ''
endfunction

" Given a buffer and a directory name, find the nearest directory by searching upwards
" through the paths relative to the given buffer.
function! ale#path#FindNearestDirectory(buffer, directory_name) abort
    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p')

    let l:relative_path = finddir(a:directory_name, l:buffer_filename . ';')

    if !empty(l:relative_path)
        return fnamemodify(l:relative_path, ':p')
    endif

    return ''
endfunction

" Given a buffer, a string to search for, an a global fallback for when
" the search fails, look for a file in parent paths, and if that fails,
" use the global fallback path instead.
function! ale#path#ResolveLocalPath(buffer, search_string, global_fallback) abort
    " Search for a locally installed file first.
    let l:path = ale#path#FindNearestFile(a:buffer, a:search_string)

    " If the serach fails, try the global executable instead.
    if empty(l:path)
        let l:path = a:global_fallback
    endif

    return l:path
endfunction

" Output 'cd <directory> && '
" This function can be used changing the directory for a linter command.
function! ale#path#CdString(directory) abort
    return 'cd ' . ale#Escape(a:directory) . ' && '
endfunction

" Output 'cd <buffer_filename_directory> && '
" This function can be used changing the directory for a linter command.
function! ale#path#BufferCdString(buffer) abort
    return ale#path#CdString(fnamemodify(bufname(a:buffer), ':p:h'))
endfunction

" Return 1 if a path is an absolute path.
function! ale#path#IsAbsolute(filename) abort
    " Check for /foo and C:\foo, etc.
    return a:filename[:0] ==# '/' || a:filename[1:2] ==# ':\'
endfunction

" Given a buffer number and a relative or absolute path, return 1 if the
" two paths represent the same file on disk.
function! ale#path#IsBufferPath(buffer, complex_filename) abort
    let l:test_filename = simplify(a:complex_filename)

    if l:test_filename[:1] ==# './'
        let l:test_filename = l:test_filename[2:]
    endif

    let l:buffer_filename = expand('#' . a:buffer . ':p')

    return l:buffer_filename ==# l:test_filename
    \   || l:buffer_filename[-len(l:test_filename):] ==# l:test_filename
endfunction

" Given a path, return every component of the path, moving upwards.
function! ale#path#Upwards(path) abort
    let l:pattern = ale#Has('win32') ? '\v/+|\\+' : '\v/+'
    let l:sep = ale#Has('win32') ? '\' : '/'
    let l:parts = split(simplify(a:path), l:pattern)
    let l:path_list = []

    while !empty(l:parts)
        call add(l:path_list, join(l:parts, l:sep))
        let l:parts = l:parts[:-2]
    endwhile

    if ale#Has('win32') && a:path =~# '^[a-zA-z]:\'
        " Add \ to C: for C:\, etc.
        let l:path_list[-1] .= '\'
    elseif a:path[0] ==# '/'
        " If the path starts with /, even on Windows, add / and / to all paths.
        call add(l:path_list, '')
        call map(l:path_list, '''/'' . v:val')
    endif

    return l:path_list
endfunction
