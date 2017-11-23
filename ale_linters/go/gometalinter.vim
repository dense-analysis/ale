" Author: Ben Reedy <https://github.com/breed808>, Jeff Willette <jrwillette88@gmail.com>
" Description: Adds support for the gometalinter suite for Go files

call ale#Set('go_gometalinter_options', '')
call ale#Set('go_gometalinter_executable', 'gometalinter')
call ale#Set('go_gometalinter_lint_package', 0)

function! ale_linters#go#gometalinter#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'go_gometalinter_executable')
endfunction

function! ale_linters#go#gometalinter#GetCommand(buffer) abort
    let l:executable = ale_linters#go#gometalinter#GetExecutable(a:buffer)
    let l:filename = expand('#' . a:buffer)
    let l:options = ale#Var(a:buffer, 'go_gometalinter_options')
    let l:lint_package = ale#Var(a:buffer, 'go_gometalinter_lint_package')

    if l:lint_package
        return ale#Escape(l:executable)
        \   . (!empty(l:options) ? ' ' . l:options : '')
        \   . ' ' . ale#Escape(fnamemodify(l:filename, ':h'))
    endif

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
    let l:dir = getcwd()
    let l:output = []

    " gometalinter always gives the output in filenames with a path that is relative to
    " the current directory, so passing `l:dir` and the match name to `GetAbsPath` should
    " compute the correct absolute filepath
    for l:match in ale_linters#go#gometalinter#GetMatches(a:lines)
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
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
