" Author: w0rp <devw0rp@gmail.com>
" Description: Echoes lint message for the current line, if any

" Controls the milliseconds delay before echoing a message.
let g:ale_echo_delay = get(g:, 'ale_echo_delay', 10)
" A string format for the echoed message.
let g:ale_echo_msg_format = get(g:, 'ale_echo_msg_format', '%code: %%s')

let s:cursor_timer = -1
let s:last_pos = [0, 0, 0]

function! ale#cursor#TruncatedEcho(original_message) abort
    let l:message = a:original_message
    " Change tabs to spaces.
    let l:message = substitute(l:message, "\t", ' ', 'g')
    " Remove any newlines in the message.
    let l:message = substitute(l:message, "\n", '', 'g')

    " We need to remember the setting for shortmess and reset it again.
    let l:shortmess_options = &l:shortmess

    try
        let l:cursor_position = getcurpos()

        " The message is truncated and saved to the history.
        setlocal shortmess+=T
        exec "norm! :echomsg l:message\n"

        " Reset the cursor position if we moved off the end of the line.
        " Using :norm and :echomsg can move the cursor off the end of the
        " line.
        if l:cursor_position != getcurpos()
            call setpos('.', l:cursor_position)
        endif
    finally
        let &l:shortmess = l:shortmess_options
    endtry
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

function! ale#cursor#EnactCursorWarnings() abort
    let l:buffer = bufnr('')

    if mode(1) isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(l:buffer)
        return
    endif

    let [l:info, l:loc] = s:FindItemAtCursor()

    if !empty(l:loc)
        call ale#cursor#EchoCursorWarningWithDelay()

        if !ale#util#ProbeWindowType('ale-preview')
            call s:ShowCursorDetail(l:info, l:loc, l:buffer, { 'stay_here': 1 })
        endif
    elseif ale#Var(l:buffer, 'cursor_detail')
        call ale#preview#CloseIfTypeMatches('ale-preview')
    endif
endfunction

function! s:EchoCursorWarning(loc, info, buffer) abort
    if !empty(a:loc)
        let a:format = ale#Var(a:buffer, 'echo_msg_format')
        let a:msg = ale#GetLocItemMessage(a:loc, a:format)
        call ale#cursor#TruncatedEcho(a:msg)
        let a:info.echoed = 1
    elseif get(a:info, 'echoed')
        " We'll only clear the echoed message when moving off errors once,
        " so we don't continually clear the echo line.
        execute 'echo'
        let a:info.echoed = 0
    endif
endfunction

function! ale#cursor#EchoCursorWarning(...) abort
    let l:buffer = bufnr('')

    if !ale#Var(l:buffer, 'echo_cursor')
        return
    endif

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode(1) isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(l:buffer)
        return
    endif

    let [l:info, l:loc] = s:FindItemAtCursor()
    call s:EchoCursorWarning(l:loc, l:info, l:buffer)
endfunction

function! ale#cursor#EchoCursorWarningWithDelay() abort
    let l:buffer = bufnr('')

    if !ale#Var(l:buffer, 'echo_cursor')
        return
    endif

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode(1) isnot# 'n'
        return
    endif

    call s:StopCursorTimer()

    let l:pos = getcurpos()[0:2]

    " Check the current buffer, line, and column number against the last
    " recorded position. If the position has actually changed, *then*
    " we should echo something. Otherwise we can end up doing processing
    " the echo message far too frequently.
    if l:pos != s:last_pos
        let l:delay = ale#Var(l:buffer, 'echo_delay')

        let s:last_pos = l:pos
        let s:cursor_timer = timer_start(
                    \   l:delay,
                    \   function('ale#cursor#EchoCursorWarning')
                    \)
    endif
endfunction

function! s:ShowCursorDetail(loc, info, buffer, options) abort
    if !empty(a:loc)
        let a:message = get(a:loc, 'detail', a:loc.text)
        " In case options have been received, pass them down to the called
        " method.

        if len(a:options)
            call ale#preview#Show(split(a:message, "\n"),{ 'stay_here': get(a:options, 'stay_here', 0) })
        else
            call ale#preview#Show(split(a:message, "\n"))
        endif

        execute 'echo'
    endif
endfunction

function! ale#cursor#ShowCursorDetail(...) abort
    let l:buffer = bufnr('')

    if !ale#Var(l:buffer, 'cursor_detail')
        return
    endif

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode() isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(l:buffer)
        return
    endif

    call s:StopCursorTimer()

    let [l:info, l:loc] = s:FindItemAtCursor()
    let l:options = get(a:000, 0, {})
    call s:ShowCursorDetail(l:loc, l:info, l:buffer, l:options)
endfunction
