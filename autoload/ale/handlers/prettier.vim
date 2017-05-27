
" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>
" Description: Integration between Prettier and ESLint.

" Here we use `prettier-eslint` intetionally,
" because from v4 it is direct mirror of `prettier` - mimics
" it's flags and etc.

let g:ale_javascript_prettier_executable =
\   get(g:, 'ale_javascript_prettier_executable', 'prettier-eslint')

let g:ale_javascript_prettier_options =
\   get(g:, 'ale_javascript_prettier_options', '')

function! ale#handlers#prettier#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'javascript_prettier_use_global')
        return ale#Var(a:buffer, 'javascript_prettier_executable')
    endif

    " Look for the kinds of paths that create-react-app generates first.
    let l:executable = ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/prettier-eslint-cli/index.js',
    \   ''
    \)

    if !empty(l:executable)
        return l:executable
    endif

    return ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/prettier-eslint',
    \   ale#Var(a:buffer, 'javascript_prettier_executable')
    \)
endfunction


function! ale#handlers#prettier#Fix(buffer, lines) abort
    let l:options = ale#Var(a:buffer, 'javascript_prettier_options')

    return {
    \   'command': ale#Escape(ale#handlers#prettier#GetExecutable(a:buffer))
    \       . ' %t'
    \       . ' ' . ale#Escape(l:options)
    \       . ' --write',
    \   'read_temporary_file': 1,
    \}
endfunction
