scriptencoding utf8
" Author: w0rp <devw0rp@gmail.com>
" Description: This module implements error/warning highlighting.

if !hlexists('ALEError')
    highlight link ALEError SpellBad
endif

if !hlexists('ALEWarning')
    highlight link ALEWarning SpellCap
endif

" This map holds highlights to be set when buffers are opened.
" We can only set highlights for whatever the current buffer is, so we will
" wait until the buffer is entered again to show the highlights, unless
" the buffer is in focus when linting completes.
let s:buffer_highlights = {}

function! ale#highlight#UnqueueHighlights(buffer) abort
    if has_key(s:buffer_highlights, a:buffer)
        call remove(s:buffer_highlights, a:buffer)
    endif
endfunction

function! s:GetALEMatches() abort
    let l:list = []

    for l:match in getmatches()
        if l:match['group'] ==# 'ALEError' || l:match['group'] ==# 'ALEWarning'
            call add(l:list, l:match)
        endif
    endfor

    return l:list
endfunction

function! s:GetCurrentMatchIDs(loclist) abort
    let l:current_id_map = {}

    for l:item in a:loclist
        if has_key(l:item, 'match_id')
            let l:current_id_map[l:item.match_id] = 1
        endif
    endfor

    return l:current_id_map
endfunction

function! ale#highlight#UpdateHighlights() abort
    let l:buffer = bufnr('%')
    let l:has_new_items = has_key(s:buffer_highlights, l:buffer)
    let l:loclist = l:has_new_items ? remove(s:buffer_highlights, l:buffer) : []
    let l:current_id_map = s:GetCurrentMatchIDs(l:loclist)
    let l:is_lintable_buffer = ale#filetypes#IsLintable(&filetype)

    if l:has_new_items || !l:is_lintable_buffer || !g:ale_enabled
        for l:match in s:GetALEMatches()
            if !has_key(l:current_id_map, l:match.id)
                call matchdelete(l:match.id)
            endif
        endfor
    endif

    " Remove anything with a current match_id
    call filter(l:loclist, '!has_key(v:val, ''match_id'')')

    if l:has_new_items
        for l:item in l:loclist
            let l:col = l:item.col
            let l:group = l:item.type ==# 'E' ? 'ALEError' : 'ALEWarning'
            let l:line = l:item.lnum
            let l:size = 1

            " Rememeber the match ID for the item.
            " This ID will be used to preserve loclist items which are set
            " many times.
            let l:item.match_id = matchaddpos(l:group, [[l:line, l:col, l:size]])
        endfor
    endif
endfunction

augroup ALEHighlightBufferGroup
    autocmd!
    autocmd BufEnter * call ale#highlight#UpdateHighlights()
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
