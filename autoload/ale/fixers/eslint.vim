" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing files with eslint.

function! ale#fixers#eslint#Fix(buffer) abort
    let l:executable = ale#handlers#eslint#GetExecutable(a:buffer)
    let l:config = ale#handlers#eslint#FindConfig(a:buffer)

    if empty(l:config)
        return 0
    endif

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' -c ' . ale#Escape(l:config)
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
