" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with paths in the filesystem.

function! ale#path#Simplify(path) abort
    " //foo is turned into /foo to stop Windows doing stupid things with
    " search paths.
    return substitute(simplify(a:path), '^//\+', '/', 'g') " no-custom-checks
endfunction

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

" Given a filename, return 1 if the file represents some temporary file
" created by Vim.
function! ale#path#IsTempName(filename) abort
    let l:prefix_list = [
    \   $TMPDIR,
    \   '/run/user',
    \]

    for l:prefix in l:prefix_list
        if a:filename[:len(l:prefix) - 1] ==# l:prefix
            return 1
        endif
    endfor

    return 0
endfunction

" Given a buffer number and a relative or absolute path, return 1 if the
" two paths represent the same file on disk.
function! ale#path#IsBufferPath(buffer, complex_filename) abort
    " If the path is one of many different names for stdin, we have a match.
    if a:complex_filename ==# '-'
    \|| a:complex_filename ==# 'stdin'
    \|| a:complex_filename[:0] ==# '<'
        return 1
    endif

    let l:test_filename = ale#path#Simplify(a:complex_filename)

    if l:test_filename[:1] ==# './'
        let l:test_filename = l:test_filename[2:]
    endif

    if l:test_filename[:1] ==# '..'
        " Remove ../../ etc. from the front of the path.
        let l:test_filename = substitute(l:test_filename, '\v^(\.\.[/\\])+', '/', '')
    endif

    " Use the basename for temporary files, as they are likely our files.
    if ale#path#IsTempName(l:test_filename)
        let l:test_filename = fnamemodify(l:test_filename, ':t')
    endif

    let l:buffer_filename = expand('#' . a:buffer . ':p')

    return l:buffer_filename ==# l:test_filename
    \   || l:buffer_filename[-len(l:test_filename):] ==# l:test_filename
endfunction

" Given a path, return every component of the path, moving upwards.
function! ale#path#Upwards(path) abort
    let l:pattern = ale#Has('win32') ? '\v/+|\\+' : '\v/+'
    let l:sep = ale#Has('win32') ? '\' : '/'
    let l:parts = split(ale#path#Simplify(a:path), l:pattern)
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
        call map(l:path_list, '''/'' . v:val')
        call add(l:path_list, '/')
    endif

    return l:path_list
endfunction
