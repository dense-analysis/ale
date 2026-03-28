function! ale#fixers#biome#Fix(buffer) abort
    let l:executable = ale#handlers#biome#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'biome_options')
    let l:unsafe = ale#Var(a:buffer, 'biome_fixer_apply_unsafe') ? ' --unsafe' : ''

    return {
    \   'command': ale#Escape(l:executable) . ' check '
    \       . '--write --stdin-file-path %s' . l:unsafe
    \       . ale#Pad(l:options)
    \}
endfunction
