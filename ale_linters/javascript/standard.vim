" Author: Patrick Lewis <patrick@patricklewis.org>
" Description: standard for JavaScript files

let g:ale_javascript_standard_executable =
\   get(g:, 'ale_standard_standard_executable', 'standard')

let g:ale_javascript_standard_use_global =
\   get(g:, 'ale_javascript_standard_use_global', 0)

function! ale_linters#javascript#standard#GetExecutable(buffer) abort
    if g:ale_javascript_standard_use_global
        return g:ale_javascript_standard_executable
    endif

    return ale#util#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/standard',
    \   g:ale_javascript_standard_executable
    \)
endfunction

function! ale_linters#javascript#standard#GetCommand(buffer) abort
    return ale_linters#javascript#standard#GetExecutable(a:buffer)
    \   . ' --stdin'
endfunction

function! ale_linters#javascript#standard#Handle(buffer, lines)
    " This pattern matches lines like the following:
    "
    " /path/to/some-filename.js:56:41: Extra semicolon.
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'

    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:type = 'Error'
        let l:text = l:match[3]

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
\   'name': 'standard',
\   'executable_callback': 'ale_linters#javascript#standard#GetExecutable',
\   'command_callback': 'ale_linters#javascript#standard#GetCommand',
\   'callback': 'ale_linters#javascript#standard#Handle',
\})
