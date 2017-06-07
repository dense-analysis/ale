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

function! ale#list#SetLists(buffer, loclist) abort
    let l:title = expand('#' . a:buffer . ':p')

    if g:ale_set_quickfix
        if has('nvim')
            call setqflist(a:loclist, ' ', l:title)
        else
            call setqflist(a:loclist)
            call setqflist([], 'r', {'title': l:title})
        endif
    elseif g:ale_set_loclist
        " If windows support is off, bufwinid() may not exist.
        " We'll set result in the current window, which might not be correct,
        " but is better than nothing.
        let l:win_id = exists('*bufwinid') ? bufwinid(str2nr(a:buffer)) : 0

        if has('nvim')
            call setloclist(l:win_id, a:loclist, ' ', l:title)
        else
            call setloclist(l:win_id, a:loclist)
            call setloclist(l:win_id, [], 'r', {'title': l:title})
        endif
    endif

    " If we have errors in our list, open the list. Only if it isn't already open
    if (g:ale_open_list && !empty(a:loclist)) || g:ale_keep_list_window_open
        let l:winnr = winnr()

        if g:ale_set_quickfix
            if !ale#list#IsQuickfixOpen()
                execute 'copen ' . str2nr(ale#Var(a:buffer, 'list_window_size'))
            endif
        elseif g:ale_set_loclist
            execute 'lopen ' . str2nr(ale#Var(a:buffer, 'list_window_size'))
        endif

        " If focus changed, restore it (jump to the last window).
        if l:winnr !=# winnr()
            wincmd p
        endif
    endif
endfunction

function! ale#list#CloseWindowIfNeeded(buffer) abort
    if g:ale_keep_list_window_open || !g:ale_open_list
        return
    endif

    " Only close windows if the quickfix list or loclist is completely empty,
    " including errors set through other means.
    if g:ale_set_quickfix
        if empty(getqflist())
            cclose
        endif
    elseif g:ale_set_loclist && empty(getloclist(0))
        lclose
    endif
endfunction
