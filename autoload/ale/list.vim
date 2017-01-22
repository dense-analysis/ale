" Author: Bjorn Neergaard <bjorn@neersighted.com>, modified by Yann fery <yann@fery.me>
" Description: Manages the loclist and quickfix lists

" Return 1 if there is a buffer with buftype == 'quickfix' in bufffer list
function! ale#list#IsQuickfixOpen() abort
    for l:buf in range(1, bufnr('$'))
        if getbufvar(l:buf, '&buftype') ==# 'quickfix'
            return 1
        endif
    endfor
    return 0
endfunction

function! ale#list#SetLists(loclist) abort
    if g:ale_set_quickfix
        call setqflist(a:loclist)
    elseif g:ale_set_loclist
        call setloclist(0, a:loclist)
    endif

    " If we don't auto-open lists, bail out here.
    if !g:ale_open_list && !g:ale_keep_list_window_open
        return
    endif

    " If we have errors in our list, open the list. Only if it isn't already open
    if len(a:loclist) > 0 || g:ale_keep_list_window_open
        let l:winnr = winnr()

        if g:ale_set_quickfix
            copen
        elseif g:ale_set_loclist
            lopen
        endif

        " If focus changed, restore it (jump to the last window).
        if l:winnr !=# winnr()
            wincmd p
        endif

        " Only close if the list is totally empty (relying on Vim's state, not our
        " own). This keeps us from closing the window when other plugins have
        " populated it.
    elseif !g:ale_keep_list_window_open && g:ale_set_quickfix && len(getqflist()) == 0
        cclose
    elseif !g:ale_keep_list_window_open && len(getloclist(0)) == 0
        lclose
    endif
endfunction
