" Author: Ian Stapleton Cordasco <graffatcolmingov@gmail.com>
" Description: Run golangci-lint with the --fix flag to autofix some issues

call ale#Set('go_golangci_lint_options', '')
call ale#Set('go_golangci_lint_executable', 'golangci-lint')
call ale#Set('go_golangci_lint_package', 1)

function! ale#fixers#golangci_lint#GetCommand(buffer) abort
    let l:filename = expand('#' . a:buffer . ':t')
    let l:executable = ale#Var(a:buffer, 'go_golangci_lint_executable')
    let l:options = ale#Var(a:buffer, 'go_golangci_lint_options') . ' --fix'
    let l:package_mode = ale#Var(a:buffer, 'go_golangci_lint_package')
    let l:env = ale#go#EnvString(a:buffer)


    if l:package_mode
        return l:env . ale#Escape(l:executable)
        \   . ' run '
        \   .  l:options
    endif

    return l:env . ale#Escape(l:executable)
    \   . ' run '
    \   . l:options
    \   . ' ' . ale#Escape(l:filename)
endfunction

function! ale#fixers#golangci_lint#Fix(buffer) abort
    return {
    \  'command': ale#fixers#golangci_lint#GetCommand(a:buffer),
    \}
endfunction
