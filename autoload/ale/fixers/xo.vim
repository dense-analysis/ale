" Author: Albert Marquez - https://github.com/a-marquez
" Description: Fixing files with XO.

function! ale#fixers#xo#Fix(buffer) abort
    let l:executable = ale#handlers#xo#GetExecutable(a:buffer, 'javascript')
    let l:options = ale#handlers#xo#GetOptions(a:buffer, 'javascript')

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' --fix %t'
    \       . ale#Pad(l:options),
    \   'read_temporary_file': 1,
    \}
endfunction
