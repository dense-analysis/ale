" Author: w0rp <devw0rp@gmail.com>
" Description: Tools for managing command history
"
function! ale#history#Add(buffer, status, job_id, command) abort
    if g:ale_max_buffer_history_size <= 0
        " Don't save anything if the history isn't a positive number.
        let g:ale_buffer_info[a:buffer].history = []

        return
    endif

    let l:history = g:ale_buffer_info[a:buffer].history

    " Remove the first item if we hit the max history size.
    if len(l:history) >= g:ale_max_buffer_history_size
        let l:history = l:history[1:]
    endif

    call add(l:history, {
    \   'status': a:status,
    \   'job_id': a:job_id,
    \   'command': a:command,
    \})

    let g:ale_buffer_info[a:buffer].history = l:history
endfunction

function! s:FindHistoryItem(buffer, job_id) abort
    " Stop immediately if there's nothing set up for the buffer.
    if !has_key(g:ale_buffer_info, a:buffer)
        return {}
    endif

    " Search backwards to find a matching job ID. IDs might be recycled,
    " so finding the last one should be good enough.
    for l:obj in reverse(g:ale_buffer_info[a:buffer].history[:])
        if l:obj.job_id == a:job_id
            return l:obj
        endif
    endfor

    return {}
endfunction

" Set an exit code for a command which finished.
function! ale#history#SetExitCode(buffer, job_id, exit_code) abort
    let l:obj = s:FindHistoryItem(a:buffer, a:job_id)

    if !empty(l:obj)
        " If we find a match, then set the code and status.
        let l:obj.exit_code = a:exit_code
        let l:obj.status = 'finished'
    endif
endfunction

" Set the output for a command which finished.
function! ale#history#RememberOutput(buffer, job_id, output) abort
    let l:obj = s:FindHistoryItem(a:buffer, a:job_id)

    if !empty(l:obj)
        let l:obj.output = a:output
    endif
endfunction
