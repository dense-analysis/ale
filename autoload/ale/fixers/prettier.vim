" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>,
"         w0rp <devw0rp@gmail.com>
" Description: Integration of Prettier with ALE.

call ale#Set('javascript_prettier_executable', 'prettier')
call ale#Set('javascript_prettier_use_global', 0)
call ale#Set('javascript_prettier_options', '')

function! ale#fixers#prettier#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_prettier', [
    \   'node_modules/prettier-cli/index.js',
    \   'node_modules/.bin/prettier',
    \])
endfunction

function! ale#fixers#prettier#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'javascript_prettier_options')

    return {
    \   'command': ale#Escape(ale#fixers#prettier#GetExecutable(a:buffer))
    \       . ' %t'
    \       . ' ' . l:options
    \       . ' --write',
    \   'read_temporary_file': 1,
    \}
endfunction
