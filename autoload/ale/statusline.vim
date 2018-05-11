" Author: KabbAmine <amine.kabb@gmail.com>
" Description: Statusline related function(s)

function! s:CreateCountDict() abort
    return {
    \   'error': 0,
    \   'warning': 0,
    \   'info': 0,
    \   'style_error': 0,
    \   'style_warning': 0,
    \   'total': 0,
    \}
endfunction

" Update the buffer error/warning count with data from loclist.
function! ale#statusline#Update(buffer, loclist) abort
    if !exists('g:ale_buffer_info') || !has_key(g:ale_buffer_info, a:buffer)
        return
    endif

    let l:loclist = filter(copy(a:loclist), 'v:val.bufnr == a:buffer')
    let l:count = s:CreateCountDict()
    let l:count.total = len(l:loclist)

    for l:entry in l:loclist
        if l:entry.type is# 'W'
            if get(l:entry, 'sub_type', '') is# 'style'
                let l:count.style_warning += 1
            else
                let l:count.warning += 1
            endif
        elseif l:entry.type is# 'I'
            let l:count.info += 1
        elseif get(l:entry, 'sub_type', '') is# 'style'
            let l:count.style_error += 1
        else
            let l:count.error += 1
        endif
    endfor

    let g:ale_buffer_info[a:buffer].count = l:count
endfunction

" Returns a Dictionary with counts for use in third party integrations.
function! ale#statusline#Count(buffer) abort
    " Check if ALE has not run (and return a dummy if so).
    if !has_key(get(g:, 'ale_buffer_info', {}), a:buffer)
        return s:CreateCountDict()
    endif

    " Cache is cold, so manually ask for an update.
    if !has_key(g:ale_buffer_info[a:buffer], 'count')
        call ale#statusline#Update(a:buffer, g:ale_buffer_info[a:buffer].loclist)
    endif

    " Return a copy here to prevent other plugins from mutating state.
    return copy(g:ale_buffer_info[a:buffer].count)
endfunction
