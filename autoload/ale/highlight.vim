scriptencoding utf8
" Author: w0rp <devw0rp@gmail.com>
" Description: This module implements error/warning highlighting.

if !hlexists('ALEError')
    highlight link ALEError SpellBad
endif

if !hlexists('ALEStyleError')
    highlight link ALEStyleError ALEError
endif

if !hlexists('ALEWarning')
    highlight link ALEWarning SpellCap
endif

if !hlexists('ALEStyleWarning')
    highlight link ALEStyleWarning ALEWarning
endif

if !hlexists('ALEInfo')
    highlight link ALEInfo ALEWarning
endif

" This map holds highlights to be set when buffers are opened.
" We can only set highlights for whatever the current buffer is, so we will
" wait until the buffer is entered again to show the highlights, unless
" the buffer is in focus when linting completes.
let s:buffer_highlights = {}
let s:buffer_restore_map = {}
" The maximum number of items for the second argument of matchaddpos()
let s:MAX_POS_VALUES = 8
let s:MAX_COL_SIZE = 1073741824 " pow(2, 30)

function! ale#highlight#CreatePositions(line, col, end_line, end_col) abort
    if a:line >= a:end_line
        " For single lines, just return the one position.
        return [[[a:line, a:col, a:end_col - a:col + 1]]]
    endif

    " Get positions from the first line at the first column, up to a large
    " integer for highlighting up to the end of the line, followed by
    " the lines in-between, for highlighting entire lines, and
    " a highlight for the last line, up to the end column.
    let l:all_positions =
    \   [[a:line, a:col, s:MAX_COL_SIZE]]
    \   + range(a:line + 1, a:end_line - 1)
    \   + [[a:end_line, 1, a:end_col]]

    return map(
    \   range(0, len(l:all_positions) - 1, s:MAX_POS_VALUES),
    \   'l:all_positions[v:val : v:val + s:MAX_POS_VALUES - 1]',
    \)
endfunction

function! ale#highlight#UnqueueHighlights(buffer) abort
    if has_key(s:buffer_highlights, a:buffer)
        call remove(s:buffer_highlights, a:buffer)
    endif

    if has_key(s:buffer_restore_map, a:buffer)
        call remove(s:buffer_restore_map, a:buffer)
    endif
endfunction

function! s:GetALEMatches() abort
    return filter(getmatches(), 'v:val.group =~# ''^ALE''')
endfunction

function! s:GetCurrentMatchIDs(loclist) abort
    let l:current_id_map = {}

    for l:item in a:loclist
        for l:id in get(l:item, 'match_id_list', [])
            let l:current_id_map[l:id] = 1
        endfor
    endfor

    return l:current_id_map
endfunction

" Given a loclist for current items to highlight, remove all highlights
" except these which have matching loclist item entries.
function! ale#highlight#RemoveHighlights(loclist) abort
    let l:current_id_map = s:GetCurrentMatchIDs(a:loclist)

    for l:match in s:GetALEMatches()
        if !has_key(l:current_id_map, l:match.id)
            call matchdelete(l:match.id)
        endif
    endfor
endfunction

function! ale#highlight#UpdateHighlights() abort
    let l:buffer = bufnr('%')
    let l:has_new_items = has_key(s:buffer_highlights, l:buffer)
    let l:loclist = l:has_new_items ? remove(s:buffer_highlights, l:buffer) : []

    if l:has_new_items || !g:ale_enabled
        call ale#highlight#RemoveHighlights(l:loclist)
    endif

    " Remove anything with a current match_id
    call filter(l:loclist, '!has_key(v:val, ''match_id_list'')')

    " Restore items from the map of hidden items,
    " if we don't have some new items to set already.
    if empty(l:loclist) && has_key(s:buffer_restore_map, l:buffer)
        let l:loclist = s:buffer_restore_map[l:buffer]
    endif

    if g:ale_enabled
        for l:item in l:loclist
            if l:item.type ==# 'W'
                if get(l:item, 'sub_type', '') ==# 'style'
                    let l:group = 'ALEStyleWarning'
                else
                    let l:group = 'ALEWarning'
                endif
            elseif l:item.type ==# 'I'
                let l:group = 'ALEInfo'
            elseif get(l:item, 'sub_type', '') ==# 'style'
                let l:group = 'ALEStyleError'
            else
                let l:group = 'ALEError'
            endif

            let l:line = l:item.lnum
            let l:col = l:item.col
            let l:end_line = get(l:item, 'end_lnum', l:line)
            let l:end_col = get(l:item, 'end_col', l:col)

            " Set all of the positions, which are chunked into Lists which
            " are as large as will be accepted by matchaddpos.
            "
            " We will remember the IDs we set, so we can preserve some
            " highlights when linting buffers after linting files.
            let l:item.match_id_list = map(
            \   ale#highlight#CreatePositions(l:line, l:col, l:end_line, l:end_col),
            \   'matchaddpos(l:group, v:val)'
            \)
        endfor
    endif
endfunction

function! ale#highlight#BufferHidden(buffer) abort
    let l:loclist = get(g:ale_buffer_info, a:buffer, {'loclist': []}).loclist

    " Remember loclist items, so they can be restored later.
    if !empty(l:loclist)
        " Remove match_ids, as they must be re-calculated when buffers are
        " shown again.
        for l:item in l:loclist
            if has_key(l:item, 'match_id_list')
                call remove(l:item, 'match_id_list')
            endif
        endfor

        let s:buffer_restore_map[a:buffer] = filter(
        \   copy(l:loclist),
        \   'v:val.bufnr == a:buffer && v:val.col > 0'
        \)

        call clearmatches()
    endif
endfunction

augroup ALEHighlightBufferGroup
    autocmd!
    autocmd BufEnter * call ale#highlight#UpdateHighlights()
    autocmd BufHidden * call ale#highlight#BufferHidden(expand('<abuf>'))
augroup END

function! ale#highlight#SetHighlights(buffer, loclist) abort
    " Only set set items for the buffer if ALE is enabled.
    if g:ale_enabled
        " Set a list of items to be set as highlights for a buffer when
        " we next open it.
        "
        " We'll filter the loclist down to items we can set now.
        let s:buffer_highlights[a:buffer] = filter(
        \   copy(a:loclist),
        \   'v:val.bufnr == a:buffer && v:val.col > 0'
        \)

        " Update highlights for the current buffer, which may or may not
        " be the buffer we just set highlights for.
        call ale#highlight#UpdateHighlights()
    endif
endfunction
