" Author: Ben Reedy <https://github.com/breed808>
" Description: Adds support for the gometalinter suite for Go files

if !exists('g:ale_go_gometalinter_options')
    let g:ale_go_gometalinter_options = ''
endif

function! ale_linters#go#gometalinter#GetCommand(buffer) abort
    let l:filename = expand('#' . a:buffer . ':p')

    return 'gometalinter --include=''^' . l:filename . '.*$'' '
    \   . ale#Var(a:buffer, 'go_gometalinter_options')
    \   . ' ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
endfunction

function! ale_linters#go#gometalinter#GetMatches(lines) abort
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):?(\d+)?:?:?(warning|error):?\s\*?(.+)$'

    return ale#util#GetMatches(a:lines, l:pattern)
endfunction

function! ale_linters#go#gometalinter#Handler(buffer, lines) abort
    let l:output = []

    for l:match in ale_linters#go#gometalinter#GetMatches(a:lines)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': tolower(l:match[4]) ==# 'warning' ? 'W' : 'E',
        \   'text': l:match[5],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'gometalinter',
\   'executable': 'gometalinter',
\   'command_callback': 'ale_linters#go#gometalinter#GetCommand',
\   'callback': 'ale_linters#go#gometalinter#Handler',
\   'lint_file': 1,
\})
