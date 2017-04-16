" Author: Ben Reedy <https://github.com/breed808>
" Description: Adds support for the gometalinter suite for Go files

if !exists('g:ale_go_gometalinter_options')
    let g:ale_go_gometalinter_options = ''
endif

function! ale_linters#go#gometalinter#GetCommand(buffer) abort
    return 'gometalinter '
    \   . ale#Var(a:buffer, 'go_gometalinter_options')
    \   . ' ' . fnameescape(fnamemodify(bufname(a:buffer), ':p:h'))
endfunction

function! ale_linters#go#gometalinter#Handler(buffer, lines) abort
    " Matches patterns line the following:
    "
    " file.go:27: missing argument for Printf("%s"): format reads arg 2, have only 1 args
    " file.go:53:10: if block ends with a return statement, so drop this else and outdent its block (move short variable declaration to its own line if necessary)
    " file.go:5:2: expected declaration, found 'STRING' "log"

    " gometalinter returns relative paths so use tail of filename as part of pattern matcher
    let l:filename = fnamemodify(bufname(a:buffer), ':t')
    let l:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'
    let l:pattern = '^' . l:path_pattern . ':\(\d\+\):\?\(\d\+\)\?:\?:\?\(warning\|error\):\?\s\*\?\(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        " Omit errors from files other than the one currently open
        if len(l:match) == 0 || l:line !~ l:filename
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': tolower(l:match[3]) ==# 'warning' ? 'W' : 'E',
        \   'nr': -1,
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
