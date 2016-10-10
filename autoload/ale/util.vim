" Author: w0rp <devw0rp@gmail.com>
" Description: Contains miscellaneous functions

function! s:FindWrapperScript() abort
    for parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let path = expand(parent . '/' . 'stdin-wrapper')

        if filereadable(path)
            if has('win32')
                return path . '.exe'
            endif

            return path
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
    return findfile(a:filename, fnamemodify(bufname(a:buffer), ':p') . ';')
endfunction

function! ale#util#GetFunction(string_or_ref) abort
    if type(a:string_or_ref) == type('')
        return function(a:string_or_ref)
    endif

    return a:string_or_ref
endfunction

function! ale#util#FixLocList(buffer, loclist) abort
    " Some errors have line numbers beyond the end of the file,
    " so we need to adjust them so they set the error at the last line
    " of the file instead.
    let last_line_number = ale#util#GetLineCount(a:buffer)

    for item in a:loclist
        if item.lnum == 0
            " When errors appear at line 0, put them at line 1 instead.
            let item.lnum = 1
        elseif item.lnum > last_line_number
            let item.lnum = last_line_number
        endif
    endfor
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
