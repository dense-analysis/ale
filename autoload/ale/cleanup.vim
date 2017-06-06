" Author: w0rp <devw0rp@gmail.com>
" Description: Utility functions related to cleaning state.

function! ale#cleanup#Buffer(buffer) abort
    if has_key(g:ale_buffer_info, a:buffer)
        call ale#engine#RemoveManagedFiles(a:buffer)

        " When buffers are removed, clear all of the jobs.
        call ale#engine#StopCurrentJobs(a:buffer, 1)

        " Clear delayed highlights for a buffer being removed.
        if g:ale_set_highlights
            call ale#highlight#UnqueueHighlights(a:buffer)
            call ale#highlight#RemoveHighlights([])
        endif

        call remove(g:ale_buffer_info, a:buffer)
    endif
endfunction
