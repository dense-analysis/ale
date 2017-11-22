" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing files with eslint.

function! ale#fixers#eslint#Fix(buffer) abort
    let l:executable = ale#handlers#eslint#GetExecutable(a:buffer)

    let l:command = ale#semver#HasVersion(l:executable)
    \   ? ''
    \   : ale#node#Executable(a:buffer, l:executable) . ' --version'

    return {
    \   'command': l:command,
    \   'chain_with': 'ale#fixers#eslint#ApplyFixForVersion',
    \}
endfunction

function! ale#fixers#eslint#ApplyFixForVersion(buffer, version_output) abort
    let l:executable = ale#handlers#eslint#GetExecutable(a:buffer)
    let l:version = ale#semver#GetVersion(l:executable, a:version_output)

    let l:config = ale#handlers#eslint#FindConfig(a:buffer)

    if empty(l:config)
        return 0
    endif

    " Use --fix-to-stdout with eslint_d
    if l:executable =~# 'eslint_d$' && ale#semver#GTE(l:version, [3, 19, 0])
        return {
        \   'command': ale#node#Executable(a:buffer, l:executable)
        \       . ' --stdin-filename %s --stdin --fix-to-stdout',
        \}
    endif

    " 4.9.0 is the first version with --fix-dry-run
    if ale#semver#GTE(l:version, [4, 9, 0])
        return {
        \   'command': ale#node#Executable(a:buffer, l:executable)
        \       . ' --stdin-filename %s --stdin --fix-dry-run',
        \}
    endif

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' -c ' . ale#Escape(l:config)
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
