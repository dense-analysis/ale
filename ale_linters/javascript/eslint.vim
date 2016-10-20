" Author: w0rp <devw0rp@gmail.com>
" Description: eslint for JavaScript files

if exists('g:loaded_ale_linters_javascript_eslint')
    finish
endif

let g:loaded_ale_linters_javascript_eslint = 1

let g:ale_javascript_eslint_executable =
\   get(g:, 'ale_javascript_eslint_executable', 'eslint')

function! ale_linters#javascript#eslint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " /path/to/some-filename.js:47:14: Missing trailing comma. [Warning/comma-dangle]
    " /path/to/some-filename.js:56:41: Missing semicolon. [Error/semi]
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\) \[\(.\+\)\]$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:type = split(l:match[4], '/')[0]
        let l:text = l:match[3] . ' [' . l:match[4] . ']'

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('javascript', {
\   'name': 'eslint',
\   'executable': g:ale_javascript_eslint_executable,
\   'command': g:ale_javascript_eslint_executable . ' -f unix --stdin --stdin-filename %s',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})
