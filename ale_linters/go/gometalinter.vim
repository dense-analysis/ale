" Author: Ben Reedy <https://github.com/breed808>
" Description: Adds support for the gometalinter suite for Go files

call ale#Set('go_gometalinter_options', '')
call ale#Set('go_gometalinter_executable', 'gometalinter')

function! ale_linters#go#gometalinter#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'go_gometalinter_executable')
endfunction

function! ale_linters#go#gometalinter#GetCommand(buffer) abort
    let l:executable = ale_linters#go#gometalinter#GetExecutable(a:buffer)
    let l:filename = expand('#' . a:buffer)
    let l:options = ale#Var(a:buffer, 'go_gometalinter_options')

    return ale#Escape(l:executable)
    \   . ' --include=' . ale#Escape('^' . ale#util#EscapePCRE(l:filename))
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' ' . ale#Escape(fnamemodify(l:filename, ':h'))
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
        \   'type': tolower(l:match[4]) is# 'warning' ? 'W' : 'E',
        \   'text': l:match[5],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'gometalinter',
\   'executable_callback': 'ale_linters#go#gometalinter#GetExecutable',
\   'command_callback': 'ale_linters#go#gometalinter#GetCommand',
\   'callback': 'ale_linters#go#gometalinter#Handler',
\   'lint_file': 1,
\})
