" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>,
"         w0rp <devw0rp@gmail.com>, morhetz (Pavel Pertsev) <morhetz@gmail.com>
" Description: Integration between Prettier and ESLint.

function! ale#fixers#prettier_eslint#SetOptionDefaults() abort
    call ale#Set('javascript_prettier_eslint_executable', 'prettier-eslint')
    call ale#Set('javascript_prettier_eslint_use_global', 0)
    call ale#Set('javascript_prettier_eslint_options', '')
    call ale#Set('javascript_prettier_eslint_legacy', 0)
endfunction

call ale#fixers#prettier_eslint#SetOptionDefaults()

function! ale#fixers#prettier_eslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_prettier_eslint', [
    \   'node_modules/prettier-eslint-cli/dist/index.js',
    \   'node_modules/.bin/prettier-eslint',
    \])
endfunction

function! ale#fixers#prettier_eslint#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'javascript_prettier_eslint_options')
    let l:executable = ale#fixers#prettier_eslint#GetExecutable(a:buffer)

    let l:config = !ale#Var(a:buffer, 'javascript_prettier_eslint_legacy')
    \   ? ale#handlers#eslint#FindConfig(a:buffer)
    \   : ''
    let l:eslint_config_option = !empty(l:config)
    \   ? ' --eslint-config-path ' . ale#Escape(l:config)
    \   : ''

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' %t'
    \       . l:eslint_config_option
    \       . (!empty(l:options) ? ' ' . l:options : '')
    \       . ' --write',
    \   'read_temporary_file': 1,
    \}
endfunction
