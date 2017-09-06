" Author: w0rp <devw0rp@gmail.com>

function! ale#events#SaveEvent(buffer) abort
    call setbufvar(a:buffer, 'ale_save_event_fired', 1)
    let l:should_lint = ale#Var(a:buffer, 'enabled') && g:ale_lint_on_save

    if g:ale_fix_on_save
        let l:will_fix = ale#fix#Fix('save_file')
        let l:should_lint = l:should_lint && !l:will_fix
    endif

    if l:should_lint
        call ale#Queue(0, 'lint_file', a:buffer)
    endif
endfunction

function! s:LintOnEnter(buffer) abort
    if ale#Var(a:buffer, 'enabled')
    \&& g:ale_lint_on_enter
    \&& has_key(b:, 'ale_file_changed')
        call remove(b:, 'ale_file_changed')
        call ale#Queue(0, 'lint_file', a:buffer)
    endif
endfunction

function! ale#events#EnterEvent(buffer) abort
    let l:filetype = getbufvar(a:buffer, '&filetype')
    call setbufvar(a:buffer, 'ale_original_filetype', l:filetype)

    call s:LintOnEnter(a:buffer)
endfunction

function! ale#events#FileTypeEvent(buffer, new_filetype) abort
    let l:filetype = getbufvar(a:buffer, 'ale_original_filetype', '')

    " If we're setting the filetype for the first time after it was blank,
    " and the option for linting on enter is off, then we should set this
    " filetype as the original filetype. Otherwise ALE will still appear to
    " lint files because of the BufEnter event, etc.
    if empty(l:filetype) && !ale#Var(a:buffer, 'lint_on_enter')
        call setbufvar(a:buffer, 'ale_original_filetype', a:new_filetype)
    elseif a:new_filetype isnot# l:filetype
        call ale#Queue(300, 'lint_file', a:buffer)
    endif
endfunction

function! ale#events#FileChangedEvent(buffer) abort
    call setbufvar(a:buffer, 'ale_file_changed', 1)

    if bufnr('') == a:buffer
        call s:LintOnEnter(a:buffer)
    endif
endfunction
