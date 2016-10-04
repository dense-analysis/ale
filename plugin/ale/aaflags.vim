" Author: w0rp <devw0rp@gmail.com>
" Description: This file sets up configuration settings for the ALE plugin.
"   Flags can be set in vimrc files and so on to disable particular features

if exists('g:loaded_ale_flags')
    finish
endif

let g:loaded_ale_flags = 1

" This flag can be set to 0 to disable linting when text is changed.
if !exists('g:ale_lint_on_text_changed')
    let g:ale_lint_on_text_changed = 1
endif

" This flag can be set with a number of milliseconds for delaying the
" execution of a linter when text is changed. The timeout will be set and
" cleared each time text is changed, so repeated edits won't trigger the
" jobs for linting until enough time has passed after editing is done.
if !exists('g:ale_lint_delay')
    let g:ale_lint_delay = 100
endif

" This flag can be set to 0 to disable linting when the buffer is entered.
if !exists('g:ale_lint_on_enter')
    let g:ale_lint_on_enter = 1
endif

" This flag can be set to 0 to disable setting the loclist.
if !exists('g:ale_set_loclist')
    let g:ale_set_loclist = 1
endif

" This flag can be set to 0 to disable setting signs.
if !exists('g:ale_set_signs')
    " Enable the flag by default if the 'signs' feature exists.
    let g:ale_set_signs = has('signs')
endif

" This flag can be set to 0 to disable echoing when the cursor moves.
if !exists('g:ale_echo_cursor')
    let g:ale_echo_cursor = 1
endif

" This flag can be set to 0 to disable warnings for trailing whitespace
if !exists('g:ale_warn_about_trailing_whitespace')
    let g:ale_warn_about_trailing_whitespace = 1
endif

" This flag can be set to 1 to keep sign gutter always open
if !exists('g:ale_sign_column_always')
    let g:ale_sign_column_always = 0
endif
