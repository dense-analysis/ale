scriptencoding utf-8
" Author: w0rp <devw0rp@gmail.com>
" Author: Luan Santos <cfcluan@gmail.com>
" Description: Shows lint message for the current line as virtualtext, if any

" Controls the milliseconds delay before showing a message.
let g:ale_virtualtext_delay = get(g:, 'ale_virtualtext_delay', 10)
let s:cursor_timer = -1
let s:last_pos = [0, 0, 0]
let s:has_virt_text = 0

" Allow disabling textprop usage to allow for more popup positioning control
let s:use_textprop = get(g:, 'ale_virtualtext_textprop', 1)

if has('nvim-0.3.2')
    let s:ns_id = nvim_create_namespace('ale')
    let s:has_virt_text = 1
elseif has('textprop') && has('popupwin')
    if s:use_textprop
        call prop_type_add('ale', {})
    endif

    let s:last_popup = -1
    let s:has_virt_text = 1
endif

function! ale#virtualtext#Clear() abort
    if !s:has_virt_text
        return
    endif

    let l:buffer = bufnr('')

    if has('nvim')
        call nvim_buf_clear_highlight(l:buffer, s:ns_id, 0, -1)
    else
        if s:last_popup != -1
            if s:use_textprop
                call prop_remove({'type': 'ale'})
            endif

            call popup_close(s:last_popup)
            let s:last_popup = -1
        endif
    endif
endfunction

function! ale#virtualtext#DefaultPopupOpts(...) abort
    return {
    \ 'line': -1,
    \ 'padding': [0, 0, 0, 1],
    \ 'mask': [[1, 1, 1, 1]],
    \ 'fixed': 1,
    \ 'wrap': 0,
    \ 'zindex': 2,
    \}
endfunction

function! ale#virtualtext#ShowMessage(loc, hl_group) abort
    if !s:has_virt_text
        return
    endif

    let l:prefix = get(g:, 'ale_virtualtext_prefix', '> ')
    let a:loc.text = a:loc.text

    if get(g:, 'ale_virtualtext_oneline', 1)
        let a:loc.text = substitute(a:loc.text, '\n', ' ', 'g')
    endif

    let l:msg = l:prefix . trim(ale#GetLocItemMessage(a:loc, get(g:, 'ale_virtualtext_msg_format', '%s')))

    if has('nvim')
        call nvim_buf_set_virtual_text(a:loc.bufnr, s:ns_id, a:loc.lnum-1, [[l:msg, a:hl_group]], {})
    else
        let l:popup_opts = get(g:, 'ale_virtualtext_popup_opts', 'ale#virtualtext#DefaultPopupOpts')
        let l:opts = function(l:popup_opts)(a:loc)

        " make sure the highlight group exists
        let l:opts['highlight'] = a:hl_group

        " set the textprop for the current line (if enabled)
        if s:use_textprop
            let l:opts['textprop'] = 'ale'
            let l:col = get(g:, 'ale_virtualtext_textprop_col', col('$'))

            call prop_add(a:loc.lnum, l:col, {'type': 'ale'})
        endif

        let s:last_popup = popup_create(l:msg, l:opts)
    endif
endfunction

function! s:StopCursorTimer() abort
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif
endfunction

function! ale#virtualtext#ShowCursorWarning(...) abort
    if !g:ale_virtualtext_cursor
        return
    endif

    let l:buffer = bufnr('')

    if mode(1) isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(l:buffer)
        return
    endif

    let [l:info, l:loc] = ale#util#FindItemAtCursor(l:buffer)

    call ale#virtualtext#Clear()

    if !empty(l:loc)
        let l:hl_group = 'ALEVirtualTextInfo'
        let l:type = get(l:loc, 'type', 'E')

        if l:type is# 'E'
            if get(l:loc, 'sub_type', '') is# 'style'
                let l:hl_group = 'ALEVirtualTextStyleError'
            else
                let l:hl_group = 'ALEVirtualTextError'
            endif
        elseif l:type is# 'W'
            if get(l:loc, 'sub_type', '') is# 'style'
                let l:hl_group = 'ALEVirtualTextStyleWarning'
            else
                let l:hl_group = 'ALEVirtualTextWarning'
            endif
        endif

        call ale#virtualtext#ShowMessage(l:loc, l:hl_group)
    endif
endfunction

function! ale#virtualtext#ShowCursorWarningWithDelay() abort
    let l:buffer = bufnr('')

    if !g:ale_virtualtext_cursor
        return
    endif

    if mode(1) isnot# 'n'
        return
    endif

    call s:StopCursorTimer()

    let l:pos = getpos('.')[0:2]

    " Check the current buffer, line, and column number against the last
    " recorded position. If the position has actually changed, *then*
    " we should show something. Otherwise we can end up doing processing
    " the show message far too frequently.
    if l:pos != s:last_pos
        let l:delay = ale#Var(l:buffer, 'virtualtext_delay')

        let s:last_pos = l:pos
        let s:cursor_timer = timer_start(
        \   l:delay,
        \   function('ale#virtualtext#ShowCursorWarning')
        \)
    endif
endfunction

