" Author: w0rp <devw0rp@gmail.com>
" Description: Echoes lint message for the current line, if any

if exists('g:loaded_ale_cursor')
    finish
endif

let g:loaded_ale_cursor = 1

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
        call ale#cursor#TruncatedEcho(loclist[index]['text'])
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
