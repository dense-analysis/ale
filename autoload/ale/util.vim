" Author: w0rp <devw0rp@gmail.com>
" Description: Contains miscellaneous functions

" A null file for sending output to nothing.
let g:ale#util#nul_file = '/dev/null'

if has('win32')
    let g:ale#util#nul_file = 'nul'
endif

" Return the number of lines for a given buffer.
function! ale#util#GetLineCount(buffer) abort
    return len(getbufline(a:buffer, 1, '$'))
endfunction

" Given a buffer and a filename, find the nearest file by searching upwards
" through the paths relative to the given buffer.
function! ale#util#FindNearestFile(buffer, filename) abort
    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p')

    let l:relative_path = findfile(a:filename, l:buffer_filename . ';')

    if !empty(l:relative_path)
        return fnamemodify(l:relative_path, ':p')
    endif

    return ''
endfunction

" Given a buffer and a directory name, find the nearest directory by searching upwards
" through the paths relative to the given buffer.
function! ale#util#FindNearestDirectory(buffer, directory_name) abort
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
function! ale#util#ResolveLocalPath(buffer, search_string, global_fallback) abort
    " Search for a locally installed file first.
    let l:path = ale#util#FindNearestFile(a:buffer, a:search_string)

    " If the serach fails, try the global executable instead.
    if empty(l:path)
        let l:path = a:global_fallback
    endif

    return l:path
endfunction

function! ale#util#GetFunction(string_or_ref) abort
    if type(a:string_or_ref) == type('')
        return function(a:string_or_ref)
    endif

    return a:string_or_ref
endfunction

function! ale#util#LocItemCompare(left, right) abort
    if a:left['lnum'] < a:right['lnum']
        return -1
    endif

    if a:left['lnum'] > a:right['lnum']
        return 1
    endif

    if a:left['col'] < a:right['col']
        return -1
    endif

    if a:left['col'] > a:right['col']
        return 1
    endif

    return 0
endfunction

" This function will perform a binary search to find a message from the
" loclist to echo when the cursor moves.
function! ale#util#BinarySearch(loclist, line, column) abort
    let l:min = 0
    let l:max = len(a:loclist) - 1
    let l:last_column_match = -1

    while 1
        if l:max < l:min
            return l:last_column_match
        endif

        let l:mid = (l:min + l:max) / 2
        let l:obj = a:loclist[l:mid]

        " Binary search to get on the same line
        if a:loclist[l:mid]['lnum'] < a:line
            let l:min = l:mid + 1
        elseif a:loclist[l:mid]['lnum'] > a:line
            let l:max = l:mid - 1
        else
            let l:last_column_match = l:mid

            " Binary search to get the same column, or near it
            if a:loclist[l:mid]['col'] < a:column
                let l:min = l:mid + 1
            elseif a:loclist[l:mid]['col'] > a:column
                let l:max = l:mid - 1
            else
                return l:mid
            endif
        endif
    endwhile
endfunction

" A function for testing if a function is running inside a sandbox.
" See :help sandbox
function! ale#util#InSandbox() abort
    try
        call setbufvar('%', '', '')
    catch /^Vim\%((\a\+)\)\=:E48/
        " E48 is the sandbox error.
        return 1
    catch
        " If we're not in a sandbox, we'll get another error about an
        " invalid buffer variable name.
    endtry

    return 0
endfunction
