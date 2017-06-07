" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing Python files with yapf.

function! ale#fixers#yapf#Fix(buffer) abort
    let l:config = ale#path#FindNearestFile(a:buffer, '.style.yapf')
    let l:config_options = !empty(l:config)
    \   ? ' --style ' . ale#Escape(l:config)
    \   : ''

    return {
    \   'command': 'yapf --no-local-style' . l:config_options,
    \}
endfunction
