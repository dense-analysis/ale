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
