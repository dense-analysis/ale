" Author: Bjorn Neergaard <bjorn@neersighted.com>, modified by Yann fery <yann@fery.me>
" Description: Manages the loclist and quickfix lists

function! ale#list#SetLists(loclist) abort
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
        " There is some flicker with lopen and copen
        " lopen Doc said 'If the window is already open and there are no recognized 
        " errors, close the window.' but that doesn't seem to work that way
        " lclose seems to be needed
        if g:ale_set_quickfix
            cwindow
            " Only for vader testing
            let g:ale_quickfix_opened = 1
        elseif g:ale_set_loclist
            lwindow
            " Only for vader testing
            let g:ale_loclist_opened = 1
        endif

        " If focus changed, restore it (jump to the last window).
        if l:winnr !=# winnr()
            wincmd p
        endif

        " Only close if the list is totally empty (relying on Vim's state, not our
        " own). This keeps us from closing the window when other plugins have
        " populated it.
    elseif g:ale_set_quickfix && len(getqflist()) == 0
        cclose
    elseif len(getloclist(0)) == 0
        lclose
    endif
endfunction
