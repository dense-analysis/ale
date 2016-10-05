" Author: w0rp <devw0rp@gmail.com>
" Description: This file sets up configuration settings for the ALE plugin.
"   Flags can be set in vimrc files and so on to disable particular features

if exists('g:loaded_ale_flags')
    finish
endif

let g:loaded_ale_flags = 1

" This flag can be set to 0 to disable linting when text is changed.
let g:ale_lint_on_text_changed = get(g:, 'ale_lint_on_text_changed', 1)

" This flag can be set with a number of milliseconds for delaying the
" execution of a linter when text is changed. The timeout will be set and
" cleared each time text is changed, so repeated edits won't trigger the
" jobs for linting until enough time has passed after editing is done.
let g:ale_lint_delay = get(g:, 'ale_lint_delay', 200)

" This flag can be set to 0 to disable linting when the buffer is entered.
let g:ale_lint_on_enter = get(g:, 'ale_lint_on_enter', 1)

" This flag can be set to 1 to enable linting when a buffer is written.
let g:ale_lint_on_save = get(g:, 'ale_lint_on_save', 0)

" This flag can be set to 0 to disable setting the loclist.
let g:ale_set_loclist = get(g:, 'ale_set_loclist', 1)

" This flag can be set to 0 to disable setting signs.
" This is enabled by default only if the 'signs' feature exists.
let g:ale_set_signs = get(g:, 'ale_set_signs', has('signs'))

" This flag can be set to 0 to disable echoing when the cursor moves.
let g:ale_echo_cursor = get(g:, 'ale_echo_cursor', 1)

" This flag can be set to 0 to disable warnings for trailing whitespace
let g:ale_warn_about_trailing_whitespace =
\   get(g:, 'ale_warn_about_trailing_whitespace', 1)

" This flag can be set to 1 to keep sign gutter always open
let g:ale_sign_column_always = get(g:, 'ale_sign_column_always', 0)
