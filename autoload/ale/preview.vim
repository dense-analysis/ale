" Author: w0rp <devw0rp@gmail.com>
" Description: Preview windows for showing whatever information in.

if !has_key(s:, 'last__list')
    let s:last_list = []
endif

if !has_key(s:, 'last_options')
    let s:last_options = {}
endif

function! ale#preview#SetLastSelection(item_list, options) abort
    let s:last_list = a:item_list
    let s:last_options = {
    \   'open_in': get(a:options, 'open_in', 'current-buffer'),
    \   'use_relative_paths': get(a:options, 'use_relative_paths', 0),
    \}
endfunction

" Open a preview window and show some lines in it.
" A second argument can be passed as a Dictionary with options. They are...
"
" filetype  - The filetype to use, defaulting to 'ale-preview'
" stay_here - If 1, stay in the window you came from.
function! ale#preview#Show(lines, ...) abort
    let l:options = get(a:000, 0, {})

    if g:ale_float_preview && exists('*nvim_open_win')
        call ale#preview#ShowFloating(a:lines, l:options)
    else
        silent pedit ALEPreviewWindow
        wincmd P

        setlocal modifiable
        setlocal noreadonly
        setlocal nobuflisted
        setlocal buftype=nofile
        setlocal bufhidden=wipe
        :%d
        call setline(1, a:lines)
        setlocal nomodifiable
        setlocal readonly
        let &l:filetype = get(l:options, 'filetype', 'ale-preview')

        for l:command in get(l:options, 'commands', [])
            call execute(l:command)
        endfor

        if get(l:options, 'stay_here')
            wincmd p
        endif
    endif
endfunction

" Precondition: exists('*nvim_open_win')
function! ale#preview#ShowFloating(lines, ...) abort
    let l:options = get(a:000, 0, {})
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
    call nvim_buf_set_option(buf, 'filetype', get(l:options, 'filetype', 'ale-preview'))

    " Execute commands in window context
    let l:parent_window = nvim_get_current_win()
    call nvim_set_current_win(s:winid)

    for l:command in get(l:options, 'commands', [])
        call execute(l:command)
    endfor

    " Return to parent context if stay_here not set
    if get(l:options, 'stay_here')
        call nvim_set_current_win(l:parent_window)

        augroup NvimFloating
            autocmd CursorMoved <buffer> ++once call s:close_floating()
        augroup END
    endif

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

" Close the preview window if the filetype matches the given one.
function! ale#preview#CloseIfTypeMatches(filetype) abort
    for l:win in getwininfo()
        let l:wintype = gettabwinvar(l:win.tabnr, l:win.winnr, '&filetype')

        if l:wintype is# a:filetype
            silent! pclose!
        endif
    endfor
endfunction

" Show a location selection preview window, given some items.
" Each item should have 'filename', 'line', and 'column' keys.
function! ale#preview#ShowSelection(item_list, ...) abort
    let l:options = get(a:000, 0, {})
    let l:sep = has('win32') ? '\' : '/'
    let l:lines = []

    " Create lines to display to users.
    for l:item in a:item_list
        let l:match = get(l:item, 'match', '')
        let l:filename = l:item.filename

        if get(l:options, 'use_relative_paths')
            let l:cwd = getcwd() " no-custom-checks
            let l:filename = substitute(l:filename, '^' . l:cwd . l:sep, '', '')
        endif

        call add(
        \   l:lines,
        \   l:filename
        \       . ':' . l:item.line
        \       . ':' . l:item.column
        \       . (!empty(l:match) ? ' ' . l:match : ''),
        \)
    endfor

    call ale#preview#Show(l:lines, {'filetype': 'ale-preview-selection'})
    let b:ale_preview_item_list = a:item_list
    let b:ale_preview_item_open_in = get(l:options, 'open_in', 'current-buffer')

    " Remember preview state, so we can repeat it later.
    call ale#preview#SetLastSelection(a:item_list, l:options)
endfunction

function! ale#preview#RepeatSelection() abort
    if !empty(s:last_list)
        call ale#preview#ShowSelection(s:last_list, s:last_options)
    endif
endfunction

function! s:Open(open_in) abort
    let l:item_list = get(b:, 'ale_preview_item_list', [])
    let l:item = get(l:item_list, getpos('.')[1] - 1, {})

    if empty(l:item)
        return
    endif

    :q!

    call ale#util#Open(
    \   l:item.filename,
    \   l:item.line,
    \   l:item.column,
    \   {'open_in': a:open_in},
    \)
endfunction

function! ale#preview#OpenSelection() abort
    call s:Open(b:ale_preview_item_open_in)
endfunction

function! ale#preview#OpenSelectionInTab() abort
    call s:Open('tab')
endfunction
