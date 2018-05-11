function! ale#autocmd#InitAuGroups() abort
    if g:ale_enabled
        " This value used to be a Boolean as a Number, and is now a String.
        let l:text_changed = '' . g:ale_lint_on_text_changed

        augroup ALETriggerGroup
            if l:text_changed is? 'always' || l:text_changed is# '1'
                autocmd TextChanged,TextChangedI * call ale#Queue(g:ale_lint_delay)
            elseif l:text_changed is? 'normal'
                autocmd TextChanged * call ale#Queue(g:ale_lint_delay)
            elseif l:text_changed is? 'insert'
                autocmd TextChangedI * call ale#Queue(g:ale_lint_delay)
            endif

            if g:ale_lint_on_insert_leave
                autocmd InsertLeave * call ale#Queue(0)
            endif

            " Handle everything that needs to happen when buffers are entered.
            autocmd BufEnter * call ale#events#EnterEvent(str2nr(expand('<abuf>')))
            if g:ale_lint_on_enter
                autocmd BufWinEnter,BufRead * call ale#Queue(0, 'lint_file', str2nr(expand('<abuf>')))
                " Track when the file is changed outside of Vim.
                autocmd FileChangedShellPost * call ale#events#FileChangedEvent(str2nr(expand('<abuf>')))
            endif

            if g:ale_lint_on_save
                autocmd BufWritePost * call ale#events#SaveEvent(str2nr(expand('<abuf>')))
            endif

            if g:ale_lint_on_filetype_changed
                " Only start linting if the FileType actually changes after
                " opening a buffer. The FileType will fire when buffers are opened.
                autocmd FileType * call ale#events#FileTypeEvent(str2nr(expand('<abuf>')), expand('<amatch>'))
            endif

            " Clean up highlights when buffers are hidden.
            autocmd BufHidden * call ale#highlight#RemoveHighlights()
            " Clean up buffers automatically when they are unloaded.
            autocmd BufDelete * call ale#engine#Cleanup(str2nr(expand('<abuf>')))
            autocmd QuitPre * call ale#events#QuitEvent(str2nr(expand('<abuf>')))
        augroup END

        augroup ALECursorGroup
            if g:ale_echo_cursor
                autocmd CursorMoved,CursorHold * call ale#cursor#EchoCursorWarningWithDelay()
                " Look for a warning to echo as soon as we leave Insert mode.
                " The script's position variable used when moving the cursor will
                " not be changed here.
                autocmd InsertLeave * call ale#cursor#EchoCursorWarning()
            endif
        augroup END

        augroup ALEPatternOptionsGroup
            autocmd BufEnter,BufRead * call ale#pattern_options#SetOptions(str2nr(expand('<abuf>')))
        augroup END
    else
        silent! augroup! ALETriggerGroup
        silent! augroup! ALECursorGroup
        silent! augroup! ALEPatternOptionsGroup
    endif
endfunction
