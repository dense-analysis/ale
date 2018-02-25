" Author: neersighted <bjorn@neersighted.com>
" Description: go vet for Go files
"
" Author: John Eikenberry <jae@zhar.net>
" Description: updated to work with go1.10

function! ale_linters#go#govet#GetCommand(buffer) abort
    return ale#path#BufferCdString(a:buffer) . ' go vet .'
endfunction

function! ale_linters#go#govet#Handler(buffer, lines) abort
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):?(\d+)?:? ?(.+)$'
    let l:output = []
    let l:dir = expand('#' . a:buffer . ':p:h')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[4],
        \   'type': 'E',
        \})
    endfor
    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'go vet',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command_callback': 'ale_linters#go#govet#GetCommand',
\   'callback': 'ale_linters#go#govet#Handler',
\   'lint_file': 1,
\})
