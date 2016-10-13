" Author: KabbAmine <amine.kabb@gmail.com>
" Description: Statusline related function(s)

" Update the buffer error/warning count with data from loclist.
function! ale#statusline#Update(buffer, loclist) abort
    let l:errors = 0
    let l:warnings = 0

    for l:entry in a:loclist
        if l:entry.type ==# 'E'
            let l:errors += 1
        else
            let l:warnings += 1
        endif
    endfor

    let g:ale_buffer_count_map[a:buffer] = [l:errors, l:warnings]
endfunction

" Returns a tuple of errors and warnings for use in third-party integrations.
function! ale#statusline#Count(buffer) abort
    " Cache is cold, so manually ask for an update.
    if !has_key(g:ale_buffer_count_map, a:buffer)
        call ale#statusline#Update(a:buffer, get(g:ale_buffer_loclist_map, a:buffer, []))
    endif

    return g:ale_buffer_count_map[a:buffer]
endfunction

" Returns a formatted string that can be integrated in the statusline.
function! ale#statusline#Status() abort
    let l:buffer = bufnr('%')

    " Cache is cold, so manually ask for an update.
    if !has_key(g:ale_buffer_count_map, l:buffer)
        call ale#statusline#Update(l:buffer, get(g:ale_buffer_loclist_map, l:buffer, []))
    endif

    " Build strings based on user formatting preferences.
    let l:errors = g:ale_buffer_count_map[l:buffer][0] ?
      \ printf(g:ale_statusline_format[0], g:ale_buffer_count_map[l:buffer][0]) : ''
    let l:warnings = g:ale_buffer_count_map[l:buffer][1] ?
      \ printf(g:ale_statusline_format[1], g:ale_buffer_count_map[l:buffer][1]) : ''
    let l:no_errors = g:ale_statusline_format[2]

    " Different formats based on the combination of errors and warnings.
    if empty(l:errors) && empty(l:warnings)
        let l:res = l:no_errors
    elseif !empty(l:errors) && !empty(l:warnings)
        let l:res = printf('%s %s', l:errors, l:warnings)
    else
        let l:res = empty(l:errors) ? l:warnings : l:errors
    endif

    return l:res
endfunction
