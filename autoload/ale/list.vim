" Author: Bjorn Neergaard <bjorn@neersighted.com>, modified by Yann fery <yann@fery.me>
" Description: Manages the loclist and quickfix lists

" Return 1 if there is a buffer with buftype == 'quickfix' in bufffer list
function! ale#list#IsQuickfixOpen() abort
    for l:buf in range(1, bufnr('$'))
        if getbufvar(l:buf, '&buftype') is# 'quickfix'
            return 1
        endif
    endfor
    return 0
endfunction

" Check if we should open the list, based on the save event being fired, and
" that setting being on, or the setting just being set to `1`.
function! s:ShouldOpen(buffer) abort
    let l:val = ale#Var(a:buffer, 'open_list')
    let l:saved = getbufvar(a:buffer, 'ale_save_event_fired', 0)

    return l:val is 1 || (l:val is# 'on_save' && l:saved)
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

    let l:keep_open = ale#Var(a:buffer, 'keep_list_window_open')

    " Open a window to show the problems if we need to.
    if s:ShouldOpen(a:buffer) && (l:keep_open || !empty(a:loclist))
        let l:winnr = winnr()
        let l:mode = mode()
        let l:reset_visual_selection = l:mode is? 'v' || l:mode is# "\<c-v>"
        let l:reset_character_selection = l:mode is? 's' || l:mode is# "\<c-s>"

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

        if l:reset_visual_selection || l:reset_character_selection
            " If we were in a selection mode before, select the last selection.
            normal! gv

            if l:reset_character_selection
                " Switch back to Select mode, if we were in that.
                normal! "\<c-g>"
            endif
        endif
    endif
endfunction

function! ale#list#CloseWindowIfNeeded(buffer) abort
    if ale#Var(a:buffer, 'keep_list_window_open') || !s:ShouldOpen(a:buffer)
        return
    endif

    try
        " Only close windows if the quickfix list or loclist is completely empty,
        " including errors set through other means.
        if g:ale_set_quickfix
            if empty(getqflist())
                cclose
            endif
        elseif g:ale_set_loclist && empty(getloclist(0))
            lclose
        endif
    " Ignore 'Cannot close last window' errors.
    catch /E444/
    endtry
endfunction
