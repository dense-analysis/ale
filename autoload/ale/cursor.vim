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
        exec "norm! :echomsg message\n"
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

    if !has_key(g:ale_buffer_info, l:buffer)
        return
    endif

    let l:pos = getcurpos()
    let l:loclist = g:ale_buffer_info[l:buffer].loclist
    let l:index = ale#util#BinarySearch(l:loclist, l:pos[1], l:pos[2])

    if l:index >= 0
        let l:loc = l:loclist[l:index]
        let l:msg = s:GetMessage(l:loc.linter_name, l:loc.type, l:loc.text)
        call ale#cursor#TruncatedEcho(l:msg)
        let g:ale_buffer_info[l:buffer].echoed = 1
    else
        " We'll only clear the echoed message when moving off errors once,
        " so we don't continually clear the echo line.
        if get(g:ale_buffer_info[l:buffer], 'echoed')
            echo
            let g:ale_buffer_info[l:buffer].echoed = 0
        endif
    endif
endfunction

let s:cursor_timer = -1
let s:last_pos = [0, 0, 0]

function! ale#cursor#EchoCursorWarningWithDelay() abort
    " Do nothing for blacklisted files.
    if index(g:ale_filetype_blacklist, &filetype) >= 0
        return
    endif

    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif

    let l:pos = getcurpos()[0:2]

    " Check the current buffer, line, and column number against the last
    " recorded position. If the position has actually changed, *then*
    " we should echo something. Otherwise we can end up doing processing
    " the echo message far too frequently.
    if l:pos != s:last_pos
        let s:last_pos = l:pos
        let s:cursor_timer = timer_start(10, function('ale#cursor#EchoCursorWarning'))
    endif
endfunction
