" Author: w0rp <devw0rp@gmail.com>
" Description: Utility functions related to cleaning state.

function! ale#cleanup#Buffer(buffer) abort
    if has_key(g:ale_buffer_count_map, a:buffer)
        call remove(g:ale_buffer_count_map, a:buffer)
    endif

    if has_key(g:ale_buffer_loclist_map, a:buffer)
        call remove(g:ale_buffer_loclist_map, a:buffer)
    endif

    if has_key(g:ale_buffer_should_reset_map, a:buffer)
        call remove(g:ale_buffer_should_reset_map, a:buffer)
    endif

    if has_key(g:ale_buffer_sign_dummy_map, a:buffer)
        call remove(g:ale_buffer_sign_dummy_map, a:buffer)
    endif
endfunction
