" Author: w0rp <devw0rp@gmail.com>
" Description: This file implements functions for jumping around in a file
"   based on ALE's internal loclist.

" Search for the nearest line either before or after the current position
" in the loclist. The argument 'wrap' can be passed to enable wrapping
" around the end of the list.
"
" If there are no items or we have hit the end with wrapping off, an empty
" List will be returned, otherwise a pair of [line_number, column_number] will
" be returned.
function! ale#loclist_jumping#FindNearest(direction, wrap) abort
    let l:pos = getcurpos()
    let l:info = get(g:ale_buffer_info, bufnr('%'), {'loclist': []})
    " This list will have already been sorted.
    let l:loclist = l:info.loclist
    let l:search_item = {'lnum': l:pos[1], 'col': l:pos[2]}

    " When searching backwards, so we can find the next smallest match.
    if a:direction ==# 'before'
        let l:loclist = reverse(copy(l:loclist))
    endif

    " Look for items before or after the current position.
    for l:item in l:loclist
        " Compare the cursor with a item where the column number is bounded,
        " such that it's possible for the cursor to actually be on the given
        " column number, without modifying the cursor number we return. This
        " will allow us to move through matches, but still let us move the
        " cursor to a line without changing the column, in some cases.
        let l:cmp_value = ale#util#LocItemCompare(
        \   {
        \       'lnum': l:item.lnum,
        \       'col': min([max([l:item.col, 1]), len(getline(l:item.lnum))]),
        \   },
        \   l:search_item
        \)

        if a:direction ==# 'before' && l:cmp_value < 0
            return [l:item.lnum, l:item.col]
        endif

        if a:direction ==# 'after' && l:cmp_value > 0
            return [l:item.lnum, l:item.col]
        endif
    endfor

    " If we found nothing, and the wrap option is set to 1, then we should
    " wrap around the list of warnings/errors
    if a:wrap && !empty(l:loclist)
        let l:item = l:loclist[0]

        return [l:item.lnum, l:item.col]
    endif

    return []
endfunction

" As before, find the nearest match, but position the cursor at it.
function! ale#loclist_jumping#Jump(direction, wrap) abort
    let l:nearest = ale#loclist_jumping#FindNearest(a:direction, a:wrap)

    if !empty(l:nearest)
        call cursor(l:nearest)
    endif
endfunction

function! ale#loclist_jumping#JumpToIndex(index) abort
    let l:info = get(g:ale_buffer_info, bufnr('%'), {'loclist': []})
    let l:loclist = l:info.loclist
    if empty(l:loclist)
        return
    endif

    let l:item = l:loclist[a:index]
    if !empty(l:item)
        call cursor([l:item.lnum, l:item.col])
    endif
endfunction
