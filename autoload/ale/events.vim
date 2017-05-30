" Author: w0rp <devw0rp@gmail.com>

function! ale#events#SaveEvent() abort
    let l:should_lint = g:ale_enabled && g:ale_lint_on_save

    if g:ale_fix_on_save
        let l:will_fix = ale#fix#Fix('save_file')
        let l:should_lint = l:should_lint && !l:will_fix
    endif

    if l:should_lint
        call ale#Queue(0, 'lint_file')
    endif
endfunction
