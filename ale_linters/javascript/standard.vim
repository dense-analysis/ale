" Author: Ahmed El Gabri <@ahmedelgabri>
" Description: standardjs for JavaScript files

let g:ale_javascript_standard_executable =
\   get(g:, 'ale_javascript_standard_executable', 'standard')

let g:ale_javascript_standard_options =
\   get(g:, 'ale_javascript_standard_options', '')

let g:ale_javascript_standard_use_global =
\   get(g:, 'ale_javascript_standard_use_global', 0)

function! ale_linters#javascript#standard#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'javascript_standard_use_global')
        return ale#Var(a:buffer, 'javascript_standard_executable')
    endif

    return ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/standard',
    \   ale#Var(a:buffer, 'javascript_standard_executable')
    \)
endfunction

function! ale_linters#javascript#standard#GetCommand(buffer) abort
    return ale#Escape(ale_linters#javascript#standard#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'javascript_standard_options')
    \   . ' --stdin %s'
endfunction

function! ale_linters#javascript#standard#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " /path/to/some-filename.js:47:14: Strings must use singlequote.
    " /path/to/some-filename.js:56:41: Expected indentation of 2 spaces but found 4.
    " /path/to/some-filename.js:13:3: Parsing error: Unexpected token
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:type = 'Error'
        let l:text = l:match[3]

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': 'E',
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

