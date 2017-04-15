" Author: Joshua Rubin <joshua@rubixconsulting.com>, Ben Reedy <https://github.com/breed808>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

function! ale_linters#go#gobuild#GoEnv(buffer) abort
    if exists('s:go_env')
        return ''
    endif

    return 'go env GOPATH GOROOT'
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer, goenv_output) abort
    if !exists('s:go_env')
        let s:go_env = {
        \   'GOPATH': a:goenv_output[0],
        \   'GOROOT': a:goenv_output[1],
        \}
    endif

    " Run go test in local directory with relative path
    return 'GOPATH=' . s:go_env.GOPATH
    \   . ' cd ' . fnamemodify(bufname(a:buffer), ':.:h')
    \   . ' && go test -c -o /dev/null ./'
endfunction

function! ale_linters#go#gobuild#Handler(buffer, lines) abort
    return ale_linters#go#gobuild#HandleGoBuildErrors(a:buffer, bufname(a:buffer), a:lines)
endfunction

function! ale_linters#go#gobuild#HandleGoBuildErrors(buffer, full_filename, lines) abort
    " Matches patterns line the following:
    "
    " file.go:27: missing argument for Printf("%s"): format reads arg 2, have only 1 args
    " file.go:53:10: if block ends with a return statement, so drop this else and outdent its block (move short variable declaration to its own line if necessary)
    " file.go:5:2: expected declaration, found 'STRING' "log"

    " go test returns relative paths so use tail of filename as part of pattern matcher
    let l:filename = fnamemodify(a:full_filename, ':t')
    let l:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'
    let l:pattern = '^' . l:path_pattern . ':\(\d\+\):\?\(\d\+\)\?:\? \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        " Omit errors from imported go packages
        if len(l:match) == 0 || l:line !~ l:filename
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'executable': 'go',
\   'command_chain': [
\     {'callback': 'ale_linters#go#gobuild#GoEnv', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#GetCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale_linters#go#gobuild#Handler',
\   'lint_file': 1,
\})
