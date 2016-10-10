" Author: w0rp <devw0rp@gmail.com>
" Description: Main entry point for the plugin: sets up prefs and autocommands
"   Preferences can be set in vimrc files and so on to configure ale

if exists('g:loaded_ale')
    finish
endif
let g:loaded_ale = 1

" A flag for detecting if the required features are set.
if has('nvim')
    let g:ale_has_required_features = has('timers')
else
    let g:ale_has_required_features = has('timers') && has('job') && has('channel')
endif

if !g:ale_has_required_features
    echoerr 'ALE requires NeoVim >= 0.1.5 or Vim 8 with +timers +job +channel'
    echoerr 'Please update your editor appropriately.'
    finish
endif

" This list configures which linters are enabled for which languages.
let g:ale_linters = get(g:, 'ale_linters', {})

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

" String format for statusline
" Its a list where:
" * The 1st element is for errors
" * The 2nd element is for warnings
" * The 3rd element is when there are no errors
let g:ale_statusline_format = get(g:, 'ale_statusline_format',
\   ['%d error(s)', '%d warning(s)', 'OK']
\)

" String format for the echoed message
" A %s is mandatory
" It can contain 2 handlers: %linter%, %severity%
let g:ale_echo_msg_format = get(g:, 'ale_echo_msg_format', '%s')

" Strings used for severity in the echoed message
let g:ale_echo_msg_error_str = get(g:, 'ale_echo_msg_error_str', 'Error')
let g:ale_echo_msg_warning_str = get(g:, 'ale_echo_msg_warning_str', 'Warning')

if g:ale_lint_on_text_changed
    augroup ALERunOnTextChangedGroup
        autocmd!
        autocmd TextChanged,TextChangedI * call ale#Queue(g:ale_lint_delay)
    augroup END
endif

if g:ale_lint_on_enter
    augroup ALERunOnEnterGroup
        autocmd!
        autocmd BufEnter,BufRead * call ale#Queue(100)
    augroup END
endif

if g:ale_lint_on_save
    augroup ALERunOnSaveGroup
        autocmd!
        autocmd BufWrite * call ale#Queue(0)
    augroup END
endif

" Clean up buffers automatically when they are unloaded.
augroup ALEBufferCleanup
    autocmd!
    autocmd BufUnload * call ale#cleanup#Buffer('<abuf>')
augroup END

" Globals which each part of the plugin should use.
let g:ale_buffer_loclist_map = {}
let g:ale_buffer_should_reset_map = {}
let g:ale_buffer_sign_dummy_map = {}

" Backwards compatibility
function! ALELint(delay)
    call ale#Queue(a:delay)
endfunction
function! ALEGetStatusLine()
    call ale#statusline#Status()
endfunction
