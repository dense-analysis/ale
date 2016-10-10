" Author: w0rp <devw0rp@gmail.com>
" Description: cython syntax checking for cython files.

function! ale_linters#pyrex#cython#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " test.pyx:13:25: Expected ':', found 'NEWLINE'
    let pattern = '^.\+:\(\d\+\):\(\d\+\): \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        if l:match[3] =~# 'is not a valid module name$'
            " Skip invalid module name errors.
            continue
        endif

        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#Define('pyrex', {
\   'name': 'cython',
\   'output_stream': 'stderr',
\   'executable': 'cython',
\   'command': g:ale#util#stdin_wrapper
\       . ' .pyx cython --warning-extra -o '
\       . g:ale#util#nul_file,
\   'callback': 'ale_linters#pyrex#cython#Handle',
\})
