" Author: Ian Stapleton Cordasco <graffatcolmingov@gmail.com>
" Description: Run golangci-lint with the --fix flag to autofix some issues

call ale#Set('go_golangci_formatter_options', '')
call ale#Set('go_golangci_formatter_executable', 'golangci-lint')

function! ale#fixers#golangci_lint#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'go_golangci_formatter_executable')

    return l:executable
endfunction

function! ale#fixers#golangci_lint#GetCommand(buffer, version) abort
    let l:filename = expand('#' . a:buffer . ':t')
    let l:executable = ale#fixers#golangci_lint#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'go_golangci_formatter_options')
    let l:env = ale#go#EnvString(a:buffer)

    if ale#semver#GTE(a:version, [2, 0, 0])
        return l:env . ale#Escape(l:executable)
        \   . ' fmt --stdin '
        \   . l:options
    else
        return l:env . ale#Escape(l:executable)
        \   . ' run --fix '
        \   . l:options
        \   . ' '
        \   . ale#Escape(l:filename)
    endif
endfunction

function! ale#fixers#golangci_lint#GetCommandForVersion(buffer, version) abort
    return {
    \ 'command': ale#fixers#golangci_lint#GetCommand(a:buffer, a:version)
    \}
endfunction

function! ale#fixers#golangci_lint#Fix(buffer) abort
    let l:executable =  ale#fixers#golangci_lint#GetExecutable(a:buffer)
    let l:command = ale#fixers#golangci_lint#GetExecutable(a:buffer) . ale#Pad('--version')

    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   l:executable,
    \   l:command,
    \   function('ale#fixers#golangci_lint#GetCommandForVersion'),
    \)
endfunction
