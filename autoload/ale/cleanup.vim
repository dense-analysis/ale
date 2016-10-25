" Author: w0rp <devw0rp@gmail.com>
" Description: Utility functions related to cleaning state.

function! ale#cleanup#Buffer(buffer) abort
    if has_key(g:ale_buffer_info, a:buffer)
        " When buffers are removed, clear all of the jobs.
        for l:job in get(g:ale_buffer_info[a:buffer], 'job_list', [])
            call ale#engine#ClearJob(l:job)
        endfor

        call remove(g:ale_buffer_info, a:buffer)
    endif
endfunction
