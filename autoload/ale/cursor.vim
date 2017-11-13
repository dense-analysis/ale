" Author: w0rp <devw0rp@gmail.com>
" Description: Echoes lint message for the current line, if any

let s:cursor_timer = -1
let s:last_pos = [0, 0, 0]

" Return a formatted message according to g:ale_echo_msg_format variable
function! s:GetMessage(item) abort
    let l:msg = g:ale_echo_msg_format
    let l:severity = g:ale_echo_msg_warning_str
    let l:code = get(a:item, 'code', '')
    let l:code_repl = !empty(l:code) ? '\=submatch(1) . l:code . submatch(2)' : ''

    if a:item.type is# 'E'
        let l:severity = g:ale_echo_msg_error_str
    elseif a:item.type is# 'I'
        let l:severity = g:ale_echo_msg_info_str
    endif

    " Replace special markers with certain information.
    " \=l:variable is used to avoid escaping issues.
    let l:msg = substitute(l:msg, '\V%severity%', '\=l:severity', 'g')
    let l:msg = substitute(l:msg, '\V%linter%', '\=a:item.linter_name', 'g')
    let l:msg = substitute(l:msg, '\v\%([^\%]*)code([^\%]*)\%', l:code_repl, 'g')
    " Replace %s with the text.
    let l:msg = substitute(l:msg, '\V%s', '\=a:item.text', 'g')

    return l:msg
endfunction

function! s:EchoWithShortMess(setting, message) abort
    " We need to remember the setting for shormess and reset it again.
    let l:shortmess_options = getbufvar('%', '&shortmess')

    try
        " Turn shortmess on or off.
        if a:setting is# 'on'
            setlocal shortmess+=T
            " echomsg is needed for the message to get truncated and appear in
            " the message history.
            exec "norm! :echomsg a:message\n"
        elseif a:setting is# 'off'
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
    let l:buf = bufnr('')
    let l:info = get(g:ale_buffer_info, l:buf, {})
    let l:loclist = get(l:info, 'loclist', [])
    let l:pos = getcurpos()
    let l:index = ale#util#BinarySearch(l:loclist, l:buf, l:pos[1], l:pos[2])
    let l:loc = l:index >= 0 ? l:loclist[l:index] : {}

    return [l:info, l:loc]
endfunction

function! s:StopCursorTimer() abort
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif
endfunction

function! ale#cursor#EchoCursorWarning(...) abort
    return ale#CallWithCooldown('dont_echo_until', function('s:EchoImpl'), [])
endfunction

function! s:EchoImpl() abort
    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(bufnr(''))
        return
    endif

    let [l:info, l:loc] = s:FindItemAtCursor()

    if !empty(l:loc)
        let l:msg = s:GetMessage(l:loc)
        call ale#cursor#TruncatedEcho(l:msg)
        let l:info.echoed = 1
    elseif get(l:info, 'echoed')
        " We'll only clear the echoed message when moving off errors once,
        " so we don't continually clear the echo line.
        echo
        let l:info.echoed = 0
    endif
endfunction

function! ale#cursor#EchoCursorWarningWithDelay() abort
    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() isnot# 'n'
        return
    endif

    call s:StopCursorTimer()

    let l:pos = getcurpos()[0:2]

    " Check the current buffer, line, and column number against the last
    " recorded position. If the position has actually changed, *then*
    " we should echo something. Otherwise we can end up doing processing
    " the echo message far too frequently.
    if l:pos != s:last_pos
        let l:delay = ale#Var(bufnr(''), 'echo_delay')

        let s:last_pos = l:pos
        let s:cursor_timer = timer_start(
        \   l:delay,
        \   function('ale#cursor#EchoCursorWarning')
        \)
    endif
endfunction

function! ale#cursor#ShowCursorDetail() abort
    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(bufnr(''))
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
