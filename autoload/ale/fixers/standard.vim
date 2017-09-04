" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: Fixing files with Standard.

function! ale#fixers#standard#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_standard', [
    \   'node_modules/standard/bin/cmd.js',
    \   'node_modules/.bin/standard',
    \])
endfunction

function! ale#fixers#standard#Fix(buffer) abort
    let l:executable = ale#fixers#standard#GetExecutable(a:buffer)

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
