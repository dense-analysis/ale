" Author: w0rp <devw0rp@gmail.com>
" Description: Echoes lint message for the current line, if any

" Return a formatted message according to g:ale_echo_msg_format variable
function! s:GetMessage(linter, type, text) abort
    let l:msg = g:ale_echo_msg_format
    let l:type = a:type ==# 'E'
    \   ? g:ale_echo_msg_error_str
    \   : g:ale_echo_msg_warning_str

    " Replace handlers if they exist
    for [l:k, l:v] in items({'linter': a:linter, 'severity': l:type})
        let l:msg = substitute(l:msg, '\V%' . l:k . '%', l:v, '')
    endfor

    return printf(l:msg, a:text)
endfunction

function! s:EchoWithShortMess(setting, message) abort
    " We need to remember the setting for shormess and reset it again.
    let l:shortmess_options = getbufvar('%', '&shortmess')

    try
        " Turn shortmess on or off.
        if a:setting ==# 'on'
            setlocal shortmess+=T
            " echomsg is neede for the message to get truncated and appear in
            " the message history.
            exec "norm! :echomsg a:message\n"
        elseif a:setting ==# 'off'
            setlocal shortmess-=T
            " Regular echo is needed for printing newline characters.
            echo a:message
        else
            throw 'Invalid setting: ' . string(a:setting)
        endif
    finally
        call setbufvar('%', '&shortmess', l:shortmess_options)
    endtry
endfunction

function! ale#cursor#TruncatedEcho(message) abort
    let l:message = a:message
    " Change tabs to spaces.
    let l:message = substitute(l:message, "\t", ' ', 'g')
    " Remove any newlines in the message.
    let l:message = substitute(l:message, "\n", '', 'g')

    call s:EchoWithShortMess('on', l:message)
endfunction

function! s:FindItemAtCursor() abort
    let l:info = get(g:ale_buffer_info, bufnr('%'), {'loclist': []})
    let l:pos = getcurpos()
    let l:index = ale#util#BinarySearch(l:info.loclist, l:pos[1], l:pos[2])
    let l:loc = l:index >= 0 ? l:info.loclist[l:index] : {}

    return [l:info, l:loc]
endfunction

function! s:StopCursorTimer() abort
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif
endfunction

function! ale#cursor#EchoCursorWarning(...) abort
    if ale#ShouldDoNothing()
        return
    endif

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() !=# 'n'
        return
    endif

    let [l:info, l:loc] = s:FindItemAtCursor()

    if !empty(l:loc)
        let l:msg = s:GetMessage(l:loc.linter_name, l:loc.type, l:loc.text)
        call ale#cursor#TruncatedEcho(l:msg)
        let l:info.echoed = 1
    elseif get(l:info, 'echoed')
        " We'll only clear the echoed message when moving off errors once,
        " so we don't continually clear the echo line.
        echo
        let l:info.echoed = 0
    endif
endfunction

let s:cursor_timer = -1
let s:last_pos = [0, 0, 0]

function! ale#cursor#EchoCursorWarningWithDelay() abort
    if ale#ShouldDoNothing()
        return
    endif

    call s:StopCursorTimer()

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

function! ale#cursor#ShowCursorDetail() abort
    if ale#ShouldDoNothing()
        return
    endif

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() !=# 'n'
        return
    endif

    call s:StopCursorTimer()

    let [l:info, l:loc] = s:FindItemAtCursor()

    if !empty(l:loc)
        let l:message = get(l:loc, 'detail', l:loc.text)

        call s:EchoWithShortMess('off', l:message)

        " Set the echo marker, so we can clear it by moving the cursor.
        let l:info.echoed = 1
    endif
endfunction
