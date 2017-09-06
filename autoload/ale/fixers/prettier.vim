" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>,
"         w0rp <devw0rp@gmail.com>, morhetz (Pavel Pertsev) <morhetz@gmail.com>
" Description: Integration of Prettier with ALE.

call ale#Set('javascript_prettier_executable', 'prettier')
call ale#Set('javascript_prettier_use_global', 0)
call ale#Set('javascript_prettier_use_local_config', 0)
call ale#Set('javascript_prettier_options', '')

function! s:FindConfig(buffer) abort
    for l:filename in [
    \   '.prettierrc',
    \   'prettier.config.js',
    \   'package.json',
    \ ]

        let l:config = ale#path#FindNearestFile(a:buffer, l:filename)

        if !empty(l:config)
            return l:config
        endif
    endfor

    return ''
endfunction


function! ale#fixers#prettier#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_prettier', [
    \   'node_modules/.bin/prettier_d',
    \   'node_modules/prettier-cli/index.js',
    \   'node_modules/.bin/prettier',
    \])
endfunction

function! ale#fixers#prettier#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'javascript_prettier_options')
    let l:config = s:FindConfig(a:buffer)
    let l:use_config = ale#Var(a:buffer, 'javascript_prettier_use_local_config')
                \ && !empty(l:config)
    let l:filetype = getbufvar(a:buffer, '&filetype')

    " Append the --parser flag depending on the current filetype (unless it's
    " already set in g:javascript_prettier_options).
    if match(l:options, '--parser') == -1
        if l:filetype is# 'typescript'
            let l:parser = 'typescript'
        elseif l:filetype =~# 'css\|scss'
            let l:parser = 'postcss'
        elseif l:filetype is# 'json'
            let l:parser = 'json'
        else
            let l:parser = 'babylon'
        endif
        let l:options = (!empty(l:options) ? l:options . ' ' : '') . '--parser ' . l:parser
    endif

    return {
    \   'command': ale#Escape(ale#fixers#prettier#GetExecutable(a:buffer))
    \       . ' %t'
    \       . (!empty(l:options) ? ' ' . l:options : '')
    \       . (l:use_config ? ' --config ' . ale#Escape(l:config) : '')
    \       . ' --write',
    \   'read_temporary_file': 1,
    \}
endfunction
