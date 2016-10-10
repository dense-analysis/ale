" Author: w0rp <devw0rp@gmail.com>
" Description: Echoes lint message for the current line, if any

if exists('g:loaded_ale_cursor')
    finish
endif

let g:loaded_ale_cursor = 1

" Return a formatted message according to g:ale_echo_msg_format variable
function! s:GetMessage(linter, type, text) abort
    let msg = g:ale_echo_msg_format
    let type = a:type ==# 'E'
    \   ? g:ale_echo_msg_error_str
    \   : g:ale_echo_msg_warning_str
    " Capitalize the 1st character
    let text = toupper(a:text[0]) . a:text[1:-1]

    " Replace handlers if they exist
    for [k, v] in items({'linter': a:linter, 'severity': type})
        let msg = substitute(msg, '\V%' . k . '%', v, '')
    endfor

    return printf(msg, text)
endfunction

" This function will perform a binary search to find a message from the
" loclist to echo when the cursor moves.
function! s:BinarySearch(loclist, line, column)
    let min = 0
    let max = len(a:loclist) - 1
    let last_column_match = -1

    while 1
        if max < min
            return last_column_match
        endif

        let mid = (min + max) / 2
        let obj = a:loclist[mid]

        " Binary search to get on the same line
        if a:loclist[mid]['lnum'] < a:line
            let min = mid + 1
        elseif a:loclist[mid]['lnum'] > a:line
            let max = mid - 1
        else
            let last_column_match = mid

            " Binary search to get the same column, or near it
            if a:loclist[mid]['col'] < a:column
                let min = mid + 1
            elseif a:loclist[mid]['col'] > a:column
                let max = mid - 1
            else
                return mid
            endif
        endif
    endwhile
endfunction

function! ale#cursor#TruncatedEcho(message)
    let message = a:message
    " Change tabs to spaces.
    let message = substitute(message, "\t", ' ', 'g')
    " Remove any newlines in the message.
    let message = substitute(message, "\n", '', 'g')

    " We need to turn T for truncated messages on for shortmess,
    " and then then we need to reset the option back to what it was.
    let shortmess_options = &shortmess

    try
        " Echo the message truncated to fit without creating a prompt.
        set shortmess+=T
        exec "norm :echomsg message\n"
    finally
        let &shortmess = shortmess_options
    endtry
endfunction

function! ale#cursor#EchoCursorWarning(...)
    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() !=# 'n'
        return
    endif

    let buffer = bufnr('%')

    if !has_key(g:ale_buffer_loclist_map, buffer)
        return
    endif

    let loclist = g:ale_buffer_loclist_map[buffer]

    let pos = getcurpos()

    let index = s:BinarySearch(loclist, pos[1], pos[2])

    if index >= 0
        let l = loclist[index]
        let msg = s:GetMessage(l.linter_name, l.type, l.text)
        call ale#cursor#TruncatedEcho(msg)
    else
        echo
    endif
endfunction

let s:cursor_timer = -1

function! ale#cursor#EchoCursorWarningWithDelay()
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif

    let s:cursor_timer = timer_start(10, function('ale#cursor#EchoCursorWarning'))
endfunction

if g:ale_echo_cursor
    augroup ALECursorGroup
        autocmd!
        autocmd CursorMoved,CursorHold * call ale#cursor#EchoCursorWarningWithDelay()
    augroup END
endif
