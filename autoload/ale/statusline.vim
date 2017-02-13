" Author: KabbAmine <amine.kabb@gmail.com>
" Description: Statusline related function(s)

" Update the buffer error/warning count with data from loclist.
function! ale#statusline#Update(buffer, loclist) abort
    if !exists('g:ale_buffer_info')
        return
    endif

    if !has_key(g:ale_buffer_info, a:buffer)
        return
    endif

    let l:errors = 0
    let l:warnings = 0

    for l:entry in a:loclist
        if l:entry.type ==# 'E'
            let l:errors += 1
        else
            let l:warnings += 1
        endif
    endfor

    let g:ale_buffer_info[a:buffer].count = [l:errors, l:warnings]
endfunction

" Set the error and warning counts, calling for an update only if needed.
" If counts cannot be set, return 0.
function! s:SetupCount(buffer) abort
    if !has_key(g:ale_buffer_info, a:buffer)
        " Linters have not been run for the buffer yet, so stop here.
        return 0
    endif

    " Cache is cold, so manually ask for an update.
    if !has_key(g:ale_buffer_info[a:buffer], 'count')
        call ale#statusline#Update(a:buffer, g:ale_buffer_info[a:buffer].loclist)
    endif

    return 1
endfunction

" Returns a tuple of errors and warnings for use in third-party integrations.
function! ale#statusline#Count(buffer) abort
    if !exists('g:ale_buffer_info')
        return [0, 0]
    endif

    if !s:SetupCount(a:buffer)
        return [0, 0]
    endif

    return g:ale_buffer_info[a:buffer].count
endfunction

" Returns a formatted string that can be integrated in the statusline.
function! ale#statusline#Status() abort
    if !exists('g:ale_buffer_info')
        return 'OK'
    endif

    let [l:error_format, l:warning_format, l:no_errors] = g:ale_statusline_format
    let l:buffer = bufnr('%')

    if !s:SetupCount(l:buffer)
        return l:no_errors
    endif

    let [l:error_count, l:warning_count] = g:ale_buffer_info[l:buffer].count

    " Build strings based on user formatting preferences.
    let l:errors = l:error_count ? printf(l:error_format, l:error_count) : ''
    let l:warnings = l:warning_count ? printf(l:warning_format, l:warning_count) : ''

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
