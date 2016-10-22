" Author: Bjorn Neergaard <bjorn@neersighted.com>
" Description: Manages the loclist and quickfix lists

function! ale#list#SetLists(loclist) abort
    " Set either the quickfix list, or the loclist.
    if g:ale_set_quickfix
        call setqflist(a:loclist)
    elseif g:ale_set_loclist
        call setloclist(0, a:loclist)
    endif

    " If we don't auto-open lists, bail out here.
    if !g:ale_open_list
        return
    endif

    " If we have errors in our list, open the list.
    if len(a:loclist) > 0
        let l:winnr = winnr()
        if g:ale_set_quickfix
            copen
        elseif g:ale_set_loclist
            lopen
        end
        " If focus changed, restore it (jump to the last window).
        if l:winnr !=# winnr()
            wincmd p
        endif
    " Only close if the list is totally empty (relying on Vim's state, not our
    " own). This keeps us from closing the window when other plugins have
    " populated it.
    elseif g:ale_set_quickfix && len(getqflist()) == 0
        cclose
    elseif g:ale_set_loclist && len(getloclist(0)) == 0
        lclose
    endif
endfunction
