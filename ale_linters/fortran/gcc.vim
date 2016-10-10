" Author: w0rp <devw0rp@gmail.com>
" Description: gcc for Fortran files

if exists('g:loaded_ale_linters_fortran_gcc')
    finish
endif

let g:loaded_ale_linters_fortran_gcc = 1

" Set this option to change the GCC options for warnings for Fortran.
if !exists('g:ale_fortran_gcc_options')
    let g:ale_fortran_gcc_options = '-Wall'
endif

function! ale_linters#fortran#gcc#Handle(buffer, lines)
    " We have to match a starting line and a later ending line together,
    " like so.
    "
    " :21.34:
    " Error: Expected comma in I/O list at (1)
    let line_marker_pattern = '^:\(\d\+\)\.\(\d\+\):$'
    let message_pattern = '^\(Error\|Warning\): \(.\+\)$'
    let looking_for_message = 0
    let last_loclist_obj = {}

    let output = []

    for line in a:lines
        if looking_for_message
            let l:match = matchlist(line, message_pattern)
        else
            let l:match = matchlist(line, line_marker_pattern)
        endif

        if len(l:match) == 0
            continue
        endif

        if looking_for_message
            let looking_for_message = 0

            " Now we have the text, we can set it and add the error.
            let last_loclist_obj.text = l:match[2]
            let last_loclist_obj.type = l:match[1] ==# 'Warning' ? 'W' : 'E'
            call add(output, last_loclist_obj)
        else
            let last_loclist_obj = {
            \   'bufnr': a:buffer,
            \   'lnum': l:match[1] + 0,
            \   'vcol': 0,
            \   'col': l:match[2] + 0,
            \   'nr': -1,
            \}

            " Start looking for the message and error type.
            let looking_for_message = 1
        endif
    endfor

    return output
endfunction

call ale#linter#define('fortran', {
\   'name': 'gcc',
\   'output_stream': 'stderr',
\   'executable': 'gcc',
\   'command': 'gcc -S -x f95 -fsyntax-only -ffree-form '
\       . g:ale_fortran_gcc_options
\       . ' -',
\   'callback': 'ale_linters#fortran#gcc#Handle',
\})
