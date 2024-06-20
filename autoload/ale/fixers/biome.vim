function! ale#fixers#biome#Fix(buffer) abort
    let l:executable = ale#handlers#biome#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'biome_options')

    return {
    \   'read_temporary_file': 1,
    \   'command': ale#Escape(l:executable) . ' format'
    \       . (!empty(l:options) ? ' ' . l:options : '')
    \       . ' %t'
    \}
endfunction
