" Author: w0rp <devw0rp@gmail.com>
" Description: Set options in files based on regex patterns.

function! s:CmpPatterns(left_item, right_item) abort
    if a:left_item[0] < a:right_item[0]
        return -1
    endif

    if a:left_item[0] > a:right_item[0]
        return 1
    endif

    return 0
endfunction

function! ale#pattern_options#SetOptions(buffer) abort
    if !g:ale_pattern_options_enabled || empty(g:ale_pattern_options)
        return
    endif

    let l:filename = expand('#' . a:buffer . ':p')

    " The patterns are sorted, so they are applied consistently.
    for [l:pattern, l:options] in sort(
    \   items(g:ale_pattern_options),
    \   function('s:CmpPatterns')
    \)
        if match(l:filename, l:pattern) >= 0
            for [l:key, l:value] in items(l:options)
                call setbufvar(a:buffer, l:key, l:value)
            endfor
        endif
    endfor
endfunction
