" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with eslint, for checking or fixing files.

call ale#Set('javascript_eslint_executable', 'eslint')
call ale#Set('javascript_eslint_use_global', 0)

function! ale#handlers#eslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_eslint', [
    \   'node_modules/.bin/eslint_d',
    \   'node_modules/eslint/bin/eslint.js',
    \   'node_modules/.bin/eslint',
    \])
endfunction
