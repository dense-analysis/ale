" Author: w0rp <devw0rp@gmail.com>
" Description: Set options in files based on regex patterns.

function! ale#pattern_options#SetOptions() abort
    let l:filename = expand('%:p') " no-custom-checks
    let l:options = {}

    for l:pattern in keys(g:ale_pattern_options)
        if match(l:filename, l:pattern) >= 0
            let l:options = g:ale_pattern_options[l:pattern]
            break
        endif
    endfor

    for l:key in keys(l:options)
        if l:key[:0] is# '&'
            call setbufvar(bufnr(''), l:key, l:options[l:key])
        else
            let b:[l:key] = l:options[l:key]
        endif
    endfor
endfunction
