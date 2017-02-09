" Author: Joshua Rubin <joshua@rubixconsulting.com>
" Description: standard for JavaScript files

let g:ale_javascript_standard_executable =
\   get(g:, 'ale_javascript_standard_executable', 'standard')

let g:ale_javascript_standard_options =
\   get(g:, 'ale_javascript_standard_options', '')

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
    \   . ' ' . g:ale_javascript_standard_options
    \   . ' --stdin'
endfunction

function! ale_linters#javascript#standard#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " <text>:12:36: Extra semicolon.
    " <text>:13:25: Missing space before function parentheses.
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'W',
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
