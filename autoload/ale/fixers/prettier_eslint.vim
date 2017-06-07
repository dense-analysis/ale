" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>,
"         w0rp <devw0rp@gmail.com>
" Description: Integration between Prettier and ESLint.

call ale#Set('javascript_prettier_eslint_executable', 'prettier-eslint')
call ale#Set('javascript_prettier_eslint_use_global', 0)
call ale#Set('javascript_prettier_eslint_options', '')

function! ale#fixers#prettier_eslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_prettier_eslint', [
    \   'node_modules/prettier-eslint-cli/index.js',
    \   'node_modules/.bin/prettier-eslint',
    \])
endfunction

function! ale#fixers#prettier_eslint#Fix(buffer, lines) abort
    let l:options = ale#Var(a:buffer, 'javascript_prettier_eslint_options')

    return {
    \   'command': ale#Escape(ale#fixers#prettier_eslint#GetExecutable(a:buffer))
    \       . ' %t'
    \       . ' ' . l:options
    \       . ' --write',
    \   'read_temporary_file': 1,
    \}
endfunction
