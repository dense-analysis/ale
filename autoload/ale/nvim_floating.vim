" Precondition: exists('*nvim_open_win')
function! ale#nvim_floating#Show(lines, ...) abort
    let buf = nvim_create_buf(v:false, v:false)
    let s:winid = nvim_open_win(buf, v:false, {
        \ 'relative': 'cursor',
        \ 'row': 1,
        \ 'col': 0,
        \ 'width': 42,
        \ 'height': 4,
        \ 'style': 'minimal'
        \ })
    call nvim_buf_set_option(buf, 'buftype', 'acwrite')
    call nvim_buf_set_option(buf, 'bufhidden', 'delete')
    call nvim_buf_set_option(buf, 'swapfile', v:false)
    call nvim_buf_set_name(buf, 'ale://float')

    autocmd CursorMoved <buffer> ++once call s:close_floating()

    let width = max(map(copy(a:lines), 'strdisplaywidth(v:val)'))
    let height = min([len(a:lines), 10])
    call nvim_win_set_width(s:winid, width)
    call nvim_win_set_height(s:winid, height)

    call nvim_buf_set_lines(winbufnr(s:winid), 0, -1, v:false, a:lines)
    call nvim_buf_set_option(winbufnr(s:winid), 'modified', v:false)
    call nvim_buf_set_option(buf, 'modifiable', v:false)
endfunction

function! s:close_floating() abort
    call setbufvar(winbufnr(s:winid), '&modified', 0)

    if win_id2win(s:winid) > 0
        execute win_id2win(s:winid).'wincmd c'
    endif

    let s:winid = 0
endfunction
