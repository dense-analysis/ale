function! ale#fixers#biome#Fix(buffer) abort
    let l:executable = ale#handlers#biome#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'biome_options')

    return {
    \   'command': '%e format'
    \       . (!empty(l:options) ? ' ' . l:options : '')
    \       . ' --stdin-file-path=%s',
    \}
endfunction
