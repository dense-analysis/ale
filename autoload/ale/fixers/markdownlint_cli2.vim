:scriptencoding utf-8
" Author: Horacio Sanson
" Description: Fixes Markdown files with markdownlint-cli2

call ale#Set('markdownlint_cli2_executable', 'markdownlint-cli2')
call ale#Set('markdownlint_cli2_options', '')

function! ale#fixers#markdownlint_cli2#Fix(buffer) abort
    return ale#fixers#markdownlint#FixFor(a:buffer, 'markdownlint_cli2')
endfunction
