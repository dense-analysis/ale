" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing files with autopep8.

function! ale#fixers#autopep8#Fix(buffer) abort
    let l:executable = ale#handlers#python#GetExecutable(a:buffer, 'autopep8')
    if empty(l:executable)
        return 0
    endif

    return {
    \   'command': ale#Escape(l:executable) . ' -'
    \}
endfunction
