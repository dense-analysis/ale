" Author: rhysd <https://rhysd.github.io>
" Description: Integration of fixjson with ALE.

call ale#Set('json_fixjson_executable', 'fixjson')
call ale#Set('json_fixjson_options', '')

function! ale#fixers#fixjson#Fix(buffer) abort
    let l:command = ale#Escape(ale#Var(a:buffer, 'json_fixjson_executable'))
    let l:options = ale#Var(a:buffer, 'json_fixjson_options')

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    return {
    \   'command': l:command
    \}
endfunction
