" Author: w0rp <devw0rp@gmail.com>
" Description: Main entry point for the plugin: sets up prefs and autocommands
"   Preferences can be set in vimrc files and so on to configure ale

" Sanity Checks

if exists('g:loaded_ale_dont_use_this_in_other_plugins_please')
    finish
endif

" Set a special flag used only by this plugin for preventing doubly
" loading the script.
let g:loaded_ale_dont_use_this_in_other_plugins_please = 1

" A flag for detecting if the required features are set.
if has('nvim')
    let s:has_features = has('timers')
else
    " Check if Job and Channel functions are available, instead of the
    " features. This works better on old MacVim versions.
    let s:has_features = has('timers') && exists('*job_start') && exists('*ch_close_in')
endif

if !s:has_features
    " Only output a warning if editing some special files.
    if index(['', 'gitcommit'], &filetype) == -1
        echoerr 'ALE requires NeoVim >= 0.1.5 or Vim 8 with +timers +job +channel'
        echoerr 'Please update your editor appropriately.'
    endif

    " Stop here, as it won't work.
    finish
endif

" Set this flag so that other plugins can use it, like airline.
let g:loaded_ale = 1

" Set the TMPDIR environment variable if it is not set automatically.
" This can automatically fix some environments.
if has('unix') && empty($TMPDIR)
    let $TMPDIR = '/tmp'
endif

" This global variable is used internally by ALE for tracking information for
" each buffer which linters are being run against.
let g:ale_buffer_info = {}

" User Configuration

" This option prevents ALE autocmd commands from being run for particular
" filetypes which can cause issues.
let g:ale_filetype_blacklist = ['nerdtree', 'unite', 'tags']

" This Dictionary configures which linters are enabled for which languages.
let g:ale_linters = get(g:, 'ale_linters', {})

" This Dictionary allows users to set up filetype aliases for new filetypes.
let g:ale_linter_aliases = get(g:, 'ale_linter_aliases', {})

" This flag can be set with a number of milliseconds for delaying the
" execution of a linter when text is changed. The timeout will be set and
" cleared each time text is changed, so repeated edits won't trigger the
" jobs for linting until enough time has passed after editing is done.
let g:ale_lint_delay = get(g:, 'ale_lint_delay', 200)

" This flag can be set to 0 to disable linting when text is changed.
let g:ale_lint_on_text_changed = get(g:, 'ale_lint_on_text_changed', 1)

" This flag can be set to 0 to disable linting when the buffer is entered.
let g:ale_lint_on_enter = get(g:, 'ale_lint_on_enter', 1)

" This flag can be set to 1 to enable linting when a buffer is written.
let g:ale_lint_on_save = get(g:, 'ale_lint_on_save', 0)

" This flag may be set to 0 to disable ale. After ale is loaded, :ALEToggle
" should be used instead.
let g:ale_enabled = get(g:, 'ale_enabled', 1)

" These flags dictates if ale uses the quickfix or the loclist (loclist is the
" default, quickfix overrides loclist).
let g:ale_set_loclist = get(g:, 'ale_set_loclist', 1)
let g:ale_set_quickfix = get(g:, 'ale_set_quickfix', 0)

" This flag dictates if ale open the configured loclist
let g:ale_open_list = get(g:, 'ale_open_list', 0)

" This flag dictates if ale keeps open loclist even if there is no error in loclist
let g:ale_keep_list_window_open = get(g:, 'ale_keep_list_window_open', 0)

" This flag can be set to 0 to disable setting signs.
" This is enabled by default only if the 'signs' feature exists.
let g:ale_set_signs = get(g:, 'ale_set_signs', has('signs'))

" This flag can be set to 0 to disable setting error highlights.
let g:ale_set_highlights = get(g:, 'ale_set_highlights', has('syntax'))

" These variables dicatate what sign is used to indicate errors and warnings.
let g:ale_sign_error = get(g:, 'ale_sign_error', '>>')
let g:ale_sign_warning = get(g:, 'ale_sign_warning', '--')

" This variable sets an offset which can be set for sign IDs.
" This ID can be changed depending on what IDs are set for other plugins.
" The dummy sign will use the ID exactly equal to the offset.
let g:ale_sign_offset = get(g:, 'ale_sign_offset', 1000000)

" This flag can be set to 1 to keep sign gutter always open
let g:ale_sign_column_always = get(g:, 'ale_sign_column_always', 0)

" String format for the echoed message
" A %s is mandatory
" It can contain 2 handlers: %linter%, %severity%
let g:ale_echo_msg_format = get(g:, 'ale_echo_msg_format', '%s')

" Strings used for severity in the echoed message
let g:ale_echo_msg_error_str = get(g:, 'ale_echo_msg_error_str', 'Error')
let g:ale_echo_msg_warning_str = get(g:, 'ale_echo_msg_warning_str', 'Warning')

" This flag can be set to 0 to disable echoing when the cursor moves.
let g:ale_echo_cursor = get(g:, 'ale_echo_cursor', 1)

" String format for statusline
" Its a list where:
" * The 1st element is for errors
" * The 2nd element is for warnings
" * The 3rd element is when there are no errors
let g:ale_statusline_format = get(g:, 'ale_statusline_format',
\   ['%d error(s)', '%d warning(s)', 'OK']
\)

" This flag can be set to 0 to disable warnings for trailing whitespace
let g:ale_warn_about_trailing_whitespace =
\   get(g:, 'ale_warn_about_trailing_whitespace', 1)

" A flag for controlling the maximum size of the command history to store.
let g:ale_max_buffer_history_size = get(g:, 'ale_max_buffer_history_size', 20)

" A flag for enabling or disabling the command history.
let g:ale_history_enabled = get(g:, 'ale_history_enabled', 1)

" A flag for storing the full output of commands in the history.
let g:ale_history_log_output = get(g:, 'ale_history_log_output', 0)

function! s:ALEInitAuGroups() abort
    augroup ALERunOnTextChangedGroup
        autocmd!
        if g:ale_enabled && g:ale_lint_on_text_changed
            autocmd TextChanged,TextChangedI * call ale#Queue(g:ale_lint_delay)
        endif
    augroup END

    augroup ALERunOnEnterGroup
        autocmd!
        if g:ale_enabled && g:ale_lint_on_enter
            autocmd BufEnter,BufRead * call ale#Queue(300)
        endif
    augroup END

    augroup ALERunOnSaveGroup
        autocmd!
        if g:ale_enabled && g:ale_lint_on_save
            autocmd BufWrite * call ale#Queue(0)
        endif
    augroup END

    augroup ALECursorGroup
        autocmd!
        if g:ale_enabled && g:ale_echo_cursor
            autocmd CursorMoved,CursorHold * call ale#cursor#EchoCursorWarningWithDelay()
            " Look for a warning to echo as soon as we leave Insert mode.
            " The script's position variable used when moving the cursor will
            " not be changed here.
            autocmd InsertLeave * call ale#cursor#EchoCursorWarning()
        endif
    augroup END

    if !g:ale_enabled
        augroup! ALERunOnTextChangedGroup
        augroup! ALERunOnEnterGroup
        augroup! ALERunOnSaveGroup
        augroup! ALECursorGroup
    endif
endfunction

function! s:ALEToggle() abort
    let g:ale_enabled = !get(g:, 'ale_enabled')

    if g:ale_enabled
        " Lint immediately
        call ale#Queue(0)
    else
        for l:buffer in keys(g:ale_buffer_info)
            " Stop jobs and delete stored buffer data
            call ale#cleanup#Buffer(l:buffer)
            " Clear signs, loclist, quicklist
            call ale#engine#SetResults(l:buffer, [])
        endfor

        " Remove highlights for the current buffer now.
        if g:ale_set_highlights
            call ale#highlight#UpdateHighlights()
        endif
    endif

    call s:ALEInitAuGroups()
endfunction

call s:ALEInitAuGroups()

" Define commands for moving through warnings and errors.
command! ALEPrevious :call ale#loclist_jumping#Jump('before', 0)
command! ALEPreviousWrap :call ale#loclist_jumping#Jump('before', 1)
command! ALENext :call ale#loclist_jumping#Jump('after', 0)
command! ALENextWrap :call ale#loclist_jumping#Jump('after', 1)

" A command for showing error details.
command! ALEDetail :call ale#cursor#ShowCursorDetail()

" A command for turning ALE on or off.
command! ALEToggle :call s:ALEToggle()
" A command for linting manually.
command! ALELint :call ale#Queue(0)

" Define a command to get information about current filetype.
command! ALEInfo :call ale#debugging#Info()
" The same, but copy output to your clipboard.
command! ALEInfoToClipboard :call ale#debugging#InfoToClipboard()

" <Plug> mappings for commands
nnoremap <silent> <Plug>(ale_previous) :ALEPrevious<Return>
nnoremap <silent> <Plug>(ale_previous_wrap) :ALEPreviousWrap<Return>
nnoremap <silent> <Plug>(ale_next) :ALENext<Return>
nnoremap <silent> <Plug>(ale_next_wrap) :ALENextWrap<Return>
nnoremap <silent> <Plug>(ale_toggle) :ALEToggle<Return>
nnoremap <silent> <Plug>(ale_lint) :ALELint<Return>
nnoremap <silent> <Plug>(ale_detail) :ALEDetail<Return>

" Housekeeping

augroup ALECleanupGroup
    autocmd!
    " Clean up buffers automatically when they are unloaded.
    autocmd BufUnload * call ale#cleanup#Buffer(expand('<abuf>'))
augroup END

" Backwards Compatibility

function! ALELint(delay) abort
    call ale#Queue(a:delay)
endfunction

function! ALEGetStatusLine() abort
    return ale#statusline#Status()
endfunction
