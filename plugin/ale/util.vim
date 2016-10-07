" Author: w0rp <devw0rp@gmail.com>
" Description: Contains miscellaneous functions

if exists('g:loaded_ale_util')
    finish
endif

let g:loaded_ale_util = 1

function! s:FindWrapperScript()
    for parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let path = expand(parent . '/' . 'stdin-wrapper')

        if filereadable(path)
            return path
        endif
    endfor
endfunction

let g:ale#util#stdin_wrapper = s:FindWrapperScript()

" Return the number of lines for a given buffer.
function! ale#util#GetLineCount(buffer)
    return len(getbufline(a:buffer, 1, '$'))
endfunction

" Given a buffer and a filename, find the nearest file by searching upwards
" through the paths relative to the given buffer.
function! ale#util#FindNearestFile(buffer, filename)
    return findfile(a:filename, fnamemodify(bufname(a:buffer), ':p') . ';')
endfunction

" A null file for sending output to nothing.
let g:ale#util#nul_file = '/dev/null'

if has('win32')
    let g:ale#util#nul_file = 'nul'
endif
