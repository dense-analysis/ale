" Author: Horacio Sanson https://github.com/hsanson
" Description: Functions for integrating with Go tools

" Paths that indicate the root path, in decreasing order of confidence. End
" directories with a slash.
let s:checks = ['go.mod', 'Gopkg.toml', 'Glide.yaml', 'vendor/', '.git/', '.hg/', '.svn/']

" Find the nearest dir listed in GOPATH and assume it the root of the go
" project.
function! ale#go#FindProjectRoot(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        for l:check in s:checks
            if l:check[-1:] is# '/'
                if isdirectory(l:path . '/' . l:check)
                    return l:path
                endif
            elseif filereadable(l:path . '/' . l:check)
                return l:path
            endif
        endfor
    endfor

    return ''
endfunction
