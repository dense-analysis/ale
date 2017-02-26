" Author: w0rp <devw0rp@gmail.com>
" Description: This file add scsslint support for SCSS support

function! ale_linters#scss#scsslint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " test.scss:2:1 [W] Indentation: Line should be indented 2 spaces, but was indented 4 spaces
    let l:pattern = '^.*:\(\d\+\):\(\d*\) \[\([^\]]\+\)\] \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        if !g:ale_warn_about_trailing_whitespace && l:match[4] =~# '^TrailingWhitespace'
            " Skip trailing whitespace warnings if that option is on.
            continue
        endif

        " vcol is needed to indicate that the column is a character
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3] ==# 'E' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('scss', {
\   'name': 'scsslint',
\   'executable': 'scss-lint',
\   'command': 'scss-lint --stdin-file-path=%s',
\   'callback': 'ale_linters#scss#scsslint#Handle',
\})
