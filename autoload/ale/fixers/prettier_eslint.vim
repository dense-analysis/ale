" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>,
"         w0rp <devw0rp@gmail.com>, morhetz (Pavel Pertsev) <morhetz@gmail.com>
" Description: Integration between Prettier and ESLint.

function! s:FindConfig(buffer) abort
    for l:filename in [
    \   '.eslintrc.js',
    \   '.eslintrc.yaml',
    \   '.eslintrc.yml',
    \   '.eslintrc.json',
    \   '.eslintrc',
    \   'package.json',
    \]
        let l:config = ale#path#FindNearestFile(a:buffer, l:filename)

        if !empty(l:config)
            return l:config
        endif
    endfor

    return ''
endfunction

call ale#Set('javascript_prettier_eslint_executable', 'prettier-eslint')
call ale#Set('javascript_prettier_eslint_use_global', 0)
call ale#Set('javascript_prettier_eslint_options', '')
call ale#Set('javascript_prettier_eslint_legacy', 0)

function! ale#fixers#prettier_eslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_prettier_eslint', [
    \   'node_modules/prettier-eslint-cli/dist/index.js',
    \   'node_modules/.bin/prettier-eslint',
    \])
endfunction

function! ale#fixers#prettier_eslint#Fix(buffer, lines) abort
    let l:options = ale#Var(a:buffer, 'javascript_prettier_eslint_options')
    let l:executable = ale#fixers#prettier_eslint#GetExecutable(a:buffer)
    let l:config = s:FindConfig(a:buffer)

    let l:eslint_config_option = ' --eslint-config-path ' . ale#Escape(l:config)
    if ale#Var(a:buffer, 'javascript_prettier_eslint_legacy')
      let l:eslint_config_option = ''
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' %t'
    \       . l:eslint_config_option
    \       . ' ' . l:options
    \       . ' --write',
    \   'read_temporary_file': 1,
    \}
endfunction
