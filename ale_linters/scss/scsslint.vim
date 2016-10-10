" Author: w0rp <devw0rp@gmail.com>
" Description: This file add scsslint support for SCSS support

if exists('g:loaded_ale_linters_scss_scsslint')
    finish
endif

let g:loaded_ale_linters_scss_scsslint = 1

function! ale_linters#scss#scsslint#Handle(buffer, lines)
    " Matches patterns like the following:
    "
    " test.scss:2:1 [W] Indentation: Line should be indented 2 spaces, but was indented 4 spaces
    let pattern = '^.*:\(\d\+\):\(\d*\) \[\([^\]]\+\)\] \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        if !g:ale_warn_about_trailing_whitespace && l:match[4] =~# '^TrailingWhitespace'
            " Skip trailing whitespace warnings if that option is on.
            continue
        endif

        " vcol is needed to indicate that the column is a character
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3] ==# 'E' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#Define('scss', {
\   'name': 'scsslint',
\   'executable': 'scss-lint',
\   'command': 'scss-lint --stdin-file-path=%s',
\   'callback': 'ale_linters#scss#scsslint#Handle',
\})
