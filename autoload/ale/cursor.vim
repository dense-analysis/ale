" Author: w0rp <devw0rp@gmail.com>
" Description: Echoes lint message for the current line, if any

" Return a formatted message according to g:ale_echo_msg_format variable
function! s:GetMessage(linter, type, text) abort
    let l:msg = g:ale_echo_msg_format
    let l:type = a:type ==# 'E'
    \   ? g:ale_echo_msg_error_str
    \   : g:ale_echo_msg_warning_str
    " Capitalize the 1st character
    let l:text = toupper(a:text[0]) . a:text[1:-1]

    " Replace handlers if they exist
    for [l:k, l:v] in items({'linter': a:linter, 'severity': l:type})
        let l:msg = substitute(l:msg, '\V%' . l:k . '%', l:v, '')
    endfor

    return printf(l:msg, l:text)
endfunction

" This function will perform a binary search to find a message from the
" loclist to echo when the cursor moves.
function! s:BinarySearch(loclist, line, column) abort
    let l:min = 0
    let l:max = len(a:loclist) - 1
    let l:last_column_match = -1

    while 1
        if l:max < l:min
            return l:last_column_match
        endif

        let l:mid = (l:min + l:max) / 2
        let l:obj = a:loclist[l:mid]

        " Binary search to get on the same line
        if a:loclist[l:mid]['lnum'] < a:line
            let l:min = l:mid + 1
        elseif a:loclist[l:mid]['lnum'] > a:line
            let l:max = l:mid - 1
        else
            let l:last_column_match = l:mid

            " Binary search to get the same column, or near it
            if a:loclist[l:mid]['col'] < a:column
                let l:min = l:mid + 1
            elseif a:loclist[l:mid]['col'] > a:column
                let l:max = l:mid - 1
            else
                return l:mid
            endif
        endif
    endwhile
endfunction

function! ale#cursor#TruncatedEcho(message) abort
    let l:message = a:message
    " Change tabs to spaces.
    let l:message = substitute(l:message, "\t", ' ', 'g')
    " Remove any newlines in the message.
    let l:message = substitute(l:message, "\n", '', 'g')

    " We need to turn T for truncated messages on for shortmess,
    " and then then we need to reset the option back to what it was.
    let l:shortmess_options = getbufvar('%', '&shortmess')

    try
        " Echo the message truncated to fit without creating a prompt.
        setlocal shortmess+=T
        exec "norm :echomsg message\n"
    finally
        call setbufvar('%', '&shortmess', l:shortmess_options)
    endtry
endfunction

function! ale#cursor#EchoCursorWarning(...) abort
    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() !=# 'n'
        return
    endif

    let l:buffer = bufnr('%')

    if !has_key(g:ale_buffer_loclist_map, l:buffer)
        return
    endif

    let l:pos = getcurpos()
    let l:loclist = g:ale_buffer_loclist_map[l:buffer]
    let l:index = s:BinarySearch(l:loclist, l:pos[1], l:pos[2])

    if l:index >= 0
        let l:loc = l:loclist[l:index]
        let l:msg = s:GetMessage(l:loc.linter_name, l:loc.type, l:loc.text)
        call ale#cursor#TruncatedEcho(l:msg)
    else
        echo
    endif
endfunction

let s:cursor_timer = -1

function! ale#cursor#EchoCursorWarningWithDelay() abort
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif

    let s:cursor_timer = timer_start(10, function('ale#cursor#EchoCursorWarning'))
endfunction
