function ale#cleanup#BufferCleanup(buffer)
    if has_key(g:ale_buffer_should_reset_map, a:buffer)
        call remove(g:ale_buffer_should_reset_map, a:buffer)
    endif

    if has_key(g:ale_buffer_loclist_map, a:buffer)
        call remove(g:ale_buffer_loclist_map, a:buffer)
    endif

    if has_key(g:ale_buffer_sign_dummy_map, a:buffer)
        call remove(g:ale_buffer_sign_dummy_map, a:buffer)
    endif
endfunction
