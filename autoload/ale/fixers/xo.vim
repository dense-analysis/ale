" Author: Albert Marquez - https://github.com/a-marquez
" Description: Fixing files with XO.

function! ale#fixers#xo#Fix(buffer) abort
    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:type = ''

    if l:filetype =~# 'javascript'
        let l:type = 'javascript'
    elseif l:filetype =~# 'typescript'
        let l:type = 'typescript'
    endif

    let l:executable = ale#handlers#xo#GetExecutable(a:buffer, l:type)
    let l:options = ale#handlers#xo#GetOptions(a:buffer, l:type)

    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   l:executable,
    \   '%e --version',
    \   {b, v -> ale#fixers#xo#ApplyFixForVersion(b, v, l:executable, l:options)}
    \)
endfunction

function! ale#fixers#xo#ApplyFixForVersion(buffer, version, executable, options) abort
    let l:executable = ale#node#Executable(a:buffer, a:executable)
    let l:options = ale#Pad(a:options)

    " 0.30.0 is the first version with a working --stdin --fix
    if ale#semver#GTE(a:version, [0, 30, 0])
        let l:project_root = ale#handlers#xo#GetProjectRoot(a:buffer)

        return {
        \   'command': ale#path#CdString(l:project_root)
        \       . l:executable
        \       . ' --stdin --stdin-filename %s'
        \       . ' --fix'
        \       . l:options,
        \}
    endif

    return {
    \   'command': l:executable
    \       . ' --fix %t'
    \       . l:options,
    \   'read_temporary_file': 1,
    \}
endfunction
