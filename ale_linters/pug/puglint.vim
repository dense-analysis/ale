" Author: w0rp - <devw0rp@gmail.com>
" Description: pug-lint for checking Pug/Jade files.

if exists('g:loaded_ale_linters_pug_puglint')
    finish
endif

let g:loaded_ale_linters_pug_puglint = 1

function! ale_linters#pug#puglint#Handle(buffer, lines)
    " Matches patterns like the following:
    "
    " temp.jade:6:1 The end of the string reached with no closing bracket ) found.
    let pattern = '^.\+:\(\d\+\):\(\d\+\) \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
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

call ale#linter#Define('pug', {
\   'name': 'puglint',
\   'executable': 'pug-lint',
\   'output_stream': 'stderr',
\   'command': g:ale#util#stdin_wrapper . ' .pug pug-lint -r inline',
\   'callback': 'ale_linters#pug#puglint#Handle',
\})
