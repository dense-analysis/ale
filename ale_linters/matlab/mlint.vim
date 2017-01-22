" Author: awlayton <alex@layton.in>
" Description: mlint for MATLAB files

let g:ale_matlab_mlint_executable =
\   get(g:, 'ale_matlab_mlint_executable', 'mlint')

function! ale_linters#matlab#mlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " L 27 (C 1): FNDEF: Terminate statement with semicolon to suppress output.
    " L 30 (C 13-15): FNDEF: A quoted string is unterminated.
    let l:pattern = '^L \(\d\+\) (C \([0-9-]\+\)): \([A-Z]\+\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:lnum = l:match[1] + 0
        let l:col = l:match[2] + 0
        let l:code = l:match[3]
        let l:text = l:match[4]

        " Suppress erroneous waring about filename
        " TODO: Enable this error when copying filename is supported
        if l:code ==# 'FNDEF'
            continue
        endif

        " vcol is needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:lnum,
        \   'vcol': 0,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('matlab', {
\   'name': 'mlint',
\   'executable': 'mlint',
\   'command': g:ale#util#stdin_wrapper .
\       ' .m ' . g:ale_matlab_mlint_executable . ' -id',
\   'output_stream': 'stderr',
\   'callback': 'ale_linters#matlab#mlint#Handle',
\})
