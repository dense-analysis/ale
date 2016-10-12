" Author: w0rp <devw0rp@gmail.com>
" Description: eslint for JavaScript files

if exists('g:loaded_ale_linters_javascript_eslint')
    finish
endif

let g:loaded_ale_linters_javascript_eslint = 1

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
        let marker_parts = l:match[4]
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

function! ale_linters#javascript#eslint#GetExecutable(buffer)
    let path = finddir('node_modules', ';')

    return path . '/.bin/eslint'
endfunction

function! ale_linters#javascript#eslint#GetCommand(buffer)
    let path = finddir('node_modules', ';')
    let env = 'env NODE_PATH=' . path . ' '
    let name = fnamemodify(bufname(a:buffer), ':.')

    return env . ale_linters#javascript#eslint#GetExecutable(a:buffer) . ' -f unix --stdin --stdin-filename ' . name
endfunction


call ALEAddLinter('javascript', {
\   'name': 'eslint',
\   'executable_callback': 'ale_linters#javascript#eslint#GetExecutable',
\   'command_callback': 'ale_linters#javascript#eslint#GetCommand',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})

call ALEAddLinter('javascript.jsx', {
\   'name': 'eslint',
\   'executable_callback': 'ale_linters#javascript#eslint#GetExecutable',
\   'command_callback': 'ale_linters#javascript#eslint#GetCommand',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})
