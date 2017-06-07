" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing Python files with yapf.

function! ale#fixers#yapf#Fix(buffer) abort
    let l:executable = ale#handlers#python#GetExecutable(a:buffer, 'yapf')
    if empty(l:executable)
        return 0
    endif

    let l:config = ale#path#FindNearestFile(a:buffer, '.style.yapf')
    let l:config_options = !empty(l:config)
    \   ? ' --style ' . ale#Escape(l:config)
    \   : ''

    return {
    \   'command': ale#Escape(l:executable) . ' --no-local-style' . l:config_options,
    \}
endfunction
