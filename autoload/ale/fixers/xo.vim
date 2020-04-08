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

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' --fix %t'
    \       . ale#Pad(l:options),
    \   'read_temporary_file': 1,
    \}
endfunction
