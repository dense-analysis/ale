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
    let pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\) \[\(.\+\)\]$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[3]
        let marker = l:match[4]
        let marker_parts = split(marker, '/')
        let type = marker_parts[0]

        if len(marker_parts) == 2
            let text = text . ' (' . marker_parts[1] . ')'
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#Define('javascript', {
\   'name': 'eslint',
\   'executable': g:ale_javascript_eslint_executable,
\   'command': g:ale_javascript_eslint_executable . ' -f unix --stdin --stdin-filename %s',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})

call ale#linter#Define('javascript.jsx', {
\   'name': 'eslint',
\   'executable': g:ale_javascript_eslint_executable,
\   'command': g:ale_javascript_eslint_executable . ' -f unix --stdin --stdin-filename %s',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})
