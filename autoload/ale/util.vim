" Author: w0rp <devw0rp@gmail.com>
" Description: Contains miscellaneous functions

function! s:FindWrapperScript() abort
    for l:parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let l:path = expand(l:parent . '/' . 'stdin-wrapper')

        if filereadable(l:path)
            if has('win32')
                return l:path . '.bat'
            endif

            return l:path
        endif
    endfor
endfunction

let g:ale#util#stdin_wrapper = s:FindWrapperScript()

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

    " put warnings after errors (for the same line) since the text that shows
    " when the cursor is moved will show only the first entry

    if a:left['col'] < a:right['col']
        return -1
    endif

    if a:left['col'] > a:right['col']
        return 1
    endif

    if a:left['type'] < a:right['type']
      return -1
    endif

    if a:left['type'] > a:right['type']
      return 1
    endif

    return 0
endfunction

" This function will perform a binary search to find a message from the
" loclist to echo when the cursor moves.
function! ale#util#BinarySearch(loclist, line, column) abort
    if empty(a:loclist)
      return -1
    endif

    let l:min = 0
    let l:max = len(a:loclist) - 1
    let l:last_column_match = -1

    while 1
        if l:max < l:min
            " return l:last_column_match
            let l:mid = l:last_column_match
            break
        endif

        let l:mid = (l:min + l:max) / 2

        " Binary search to get on the same line
        if a:loclist[l:mid]['lnum'] < a:line
            let l:min = l:mid + 1
            continue
        elseif a:loclist[l:mid]['lnum'] > a:line
            let l:max = l:mid - 1
            continue
        endif

        let l:last_column_match = l:mid

        " Binary search to get the same column, or near it
        if a:loclist[l:mid]['col'] < a:column
            let l:min = l:mid + 1
        elseif a:loclist[l:mid]['col'] > a:column
            let l:max = l:mid - 1
        else
            break
        endif
    endwhile

    let l:obj = a:loclist[l:mid]

    " Move backward to find the first message in loclist for the matched lnum
    " and col. The first message has the highest severity.
    while l:mid > 0
        let l:prev = a:loclist[l:mid - 1]

        if l:obj['lnum'] != l:prev['lnum']
            break
        endif

        if l:obj['col'] != l:prev['col']
            break
        endif

        let l:mid -= 1
    endwhile

    return l:mid
endfunction
