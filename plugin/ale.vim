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

" Add the after directory to the runtimepath
let &runtimepath .= ',' . expand('<sfile>:p:h:h') . '/after'

" Set this flag so that other plugins can use it, like airline.
let g:loaded_ale = 1

" Set the TMPDIR environment variable if it is not set automatically.
" This can automatically fix some environments.
if has('unix') && empty($TMPDIR)
    let $TMPDIR = '/tmp'
endif

" This flag can be set to 0 to disable emitting conflict warnings.
let g:ale_emit_conflict_warnings = get(g:, 'ale_emit_conflict_warnings', 1)

" This global variable is used internally by ALE for tracking information for
" each buffer which linters are being run against.
let g:ale_buffer_info = {}

" User Configuration

" This option prevents ALE autocmd commands from being run for particular
" filetypes which can cause issues.
let g:ale_filetype_blacklist = ['nerdtree', 'unite', 'tags']

" This Dictionary configures which linters are enabled for which languages.
let g:ale_linters = get(g:, 'ale_linters', {})

" This Dictionary configures which functions will be used for fixing problems.
let g:ale_fixers = get(g:, 'ale_fixers', {})

" This Dictionary allows users to set up filetype aliases for new filetypes.
let g:ale_linter_aliases = get(g:, 'ale_linter_aliases', {})

" This flag can be set with a number of milliseconds for delaying the
" execution of a linter when text is changed. The timeout will be set and
" cleared each time text is changed, so repeated edits won't trigger the
" jobs for linting until enough time has passed after editing is done.
let g:ale_lint_delay = get(g:, 'ale_lint_delay', 200)

" This flag can be set to 'never' to disable linting when text is changed.
" This flag can also be set to 'insert' or 'normal' to lint when text is
" changed only in insert or normal mode respectively.
let g:ale_lint_on_text_changed = get(g:, 'ale_lint_on_text_changed', 'always')

" This flag can be set to 1 to enable linting when leaving insert mode.
let g:ale_lint_on_insert_leave = get(g:, 'ale_lint_on_insert_leave', 0)

" This flag can be set to 0 to disable linting when the buffer is entered.
let g:ale_lint_on_enter = get(g:, 'ale_lint_on_enter', 1)

" This flag can be set to 1 to enable linting when a buffer is written.
let g:ale_lint_on_save = get(g:, 'ale_lint_on_save', 1)

" This flag can be set to 1 to enable linting when the filetype is changed.
let g:ale_lint_on_filetype_changed = get(g:, 'ale_lint_on_filetype_changed', 1)

call ale#Set('fix_on_save', 0)

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

" The window size to set for the quickfix and loclist windows
call ale#Set('list_window_size', 10)

" This flag can be set to 0 to disable setting signs.
" This is enabled by default only if the 'signs' feature exists.
let g:ale_set_signs = get(g:, 'ale_set_signs', has('signs'))

" This flag can be set to 1 to enable changing the sign column colors when
" there are errors.
call ale#Set('change_sign_column_color', 0)

" This flag can be set to 0 to disable setting error highlights.
let g:ale_set_highlights = get(g:, 'ale_set_highlights', has('syntax'))

" These variables dictate what sign is used to indicate errors and warnings.
call ale#Set('sign_error', '>>')
call ale#Set('sign_style_error', g:ale_sign_error)
call ale#Set('sign_warning', '--')
call ale#Set('sign_style_warning', g:ale_sign_warning)
call ale#Set('sign_info', g:ale_sign_warning)

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

" This flag can be set to 0 to disable balloon support.
call ale#Set('set_balloons', has('balloon_eval'))

" A deprecated setting for ale#statusline#Status()
" See :help ale#statusline#Count() for getting status reports.
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
let g:ale_history_log_output = get(g:, 'ale_history_log_output', 1)

" A dictionary mapping regular expression patterns to arbitrary buffer
" variables to be set. Useful for configuration ALE based on filename
" patterns.
call ale#Set('pattern_options', {})
call ale#Set('pattern_options_enabled', !empty(g:ale_pattern_options))

" A maximum file size for checking for errors.
call ale#Set('maximum_file_size', 0)

" Remapping of linter problems.
call ale#Set('type_map', {})

" Enable automatic completion with LSP servers and tsserver
call ale#Set('completion_enabled', 0)
call ale#Set('completion_delay', 300)
call ale#Set('completion_max_suggestions', 20)

function! ALEInitAuGroups() abort
    " This value used to be a Boolean as a Number, and is now a String.
    let l:text_changed = '' . g:ale_lint_on_text_changed

    augroup ALEPatternOptionsGroup
        autocmd!
        if g:ale_enabled && g:ale_pattern_options_enabled
            autocmd BufEnter,BufRead * call ale#pattern_options#SetOptions()
        endif
    augroup END

    augroup ALERunOnTextChangedGroup
        autocmd!
        if g:ale_enabled
            if l:text_changed ==? 'always' || l:text_changed ==# '1'
                autocmd TextChanged,TextChangedI * call ale#Queue(g:ale_lint_delay)
            elseif l:text_changed ==? 'normal'
                autocmd TextChanged * call ale#Queue(g:ale_lint_delay)
            elseif l:text_changed ==? 'insert'
                autocmd TextChangedI * call ale#Queue(g:ale_lint_delay)
            endif
        endif
    augroup END

    augroup ALERunOnEnterGroup
        autocmd!
        if g:ale_enabled && g:ale_lint_on_enter
            autocmd BufWinEnter,BufRead * call ale#Queue(300, 'lint_file')
            " Track when the file is changed outside of Vim.
            autocmd FileChangedShellPost * call ale#events#FileChangedEvent(str2nr(expand('<abuf>')))
            " If the file has been changed, then check it again on enter.
            autocmd BufEnter * call ale#events#EnterEvent()
        endif
    augroup END

    augroup ALERunOnFiletypeChangeGroup
        autocmd!
        if g:ale_enabled && g:ale_lint_on_filetype_changed
            " Set the filetype after a buffer is opened or read.
            autocmd BufEnter,BufRead * let b:ale_original_filetype = &filetype
            " Only start linting if the FileType actually changes after
            " opening a buffer. The FileType will fire when buffers are opened.
            autocmd FileType *
            \   if has_key(b:, 'ale_original_filetype')
            \   && b:ale_original_filetype !=# expand('<amatch>')
            \|      call ale#Queue(300, 'lint_file')
            \|  endif
        endif
    augroup END

    augroup ALERunOnSaveGroup
        autocmd!
        if (g:ale_enabled && g:ale_lint_on_save) || g:ale_fix_on_save
            autocmd BufWrite * call ale#events#SaveEvent()
        endif
    augroup END

    augroup ALERunOnInsertLeave
        autocmd!
        if g:ale_enabled && g:ale_lint_on_insert_leave
            autocmd InsertLeave * call ale#Queue(0)
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
        if !g:ale_fix_on_save
            augroup! ALERunOnSaveGroup
        endif

        augroup! ALEPatternOptionsGroup
        augroup! ALERunOnTextChangedGroup
        augroup! ALERunOnEnterGroup
        augroup! ALERunOnInsertLeave
        augroup! ALECursorGroup
    endif
endfunction

function! s:ALEToggle() abort
    let g:ale_enabled = !get(g:, 'ale_enabled')

    if g:ale_enabled
        " Set pattern options again, if enabled.
        if g:ale_pattern_options_enabled
            call ale#pattern_options#SetOptions()
        endif

        " Lint immediately, including running linters against the file.
        call ale#Queue(0, 'lint_file')

        if g:ale_set_balloons
            call ale#balloon#Enable()
        endif
    else
        " Make sure the buffer number is a number, not a string,
        " otherwise things can go wrong.
        for l:buffer in map(keys(g:ale_buffer_info), 'str2nr(v:val)')
            " Stop jobs and delete stored buffer data
            call ale#cleanup#Buffer(l:buffer)
            " Clear signs, loclist, quicklist
            call ale#engine#SetResults(l:buffer, [])
        endfor

        " Remove highlights for the current buffer now.
        if g:ale_set_highlights
            call ale#highlight#UpdateHighlights()
        endif

        if g:ale_set_balloons
            call ale#balloon#Disable()
        endif
    endif

    call ALEInitAuGroups()
endfunction

call ALEInitAuGroups()

if g:ale_set_balloons
    call ale#balloon#Enable()
endif

if g:ale_completion_enabled
    call ale#completion#Enable()
endif

" Define commands for moving through warnings and errors.
command! -bar ALEPrevious :call ale#loclist_jumping#Jump('before', 0)
command! -bar ALEPreviousWrap :call ale#loclist_jumping#Jump('before', 1)
command! -bar ALENext :call ale#loclist_jumping#Jump('after', 0)
command! -bar ALENextWrap :call ale#loclist_jumping#Jump('after', 1)
command! -bar ALEFirst :call ale#loclist_jumping#JumpToIndex(0)
command! -bar ALELast :call ale#loclist_jumping#JumpToIndex(-1)

" A command for showing error details.
command! -bar ALEDetail :call ale#cursor#ShowCursorDetail()

" Define commands for turning ALE on or off.
command! -bar ALEToggle :call s:ALEToggle()
command! -bar ALEEnable :if !g:ale_enabled | ALEToggle | endif
command! -bar ALEDisable :if g:ale_enabled | ALEToggle | endif

" A command for linting manually.
command! -bar ALELint :call ale#Queue(0, 'lint_file')

" Define a command to get information about current filetype.
command! -bar ALEInfo :call ale#debugging#Info()
" The same, but copy output to your clipboard.
command! -bar ALEInfoToClipboard :call ale#debugging#InfoToClipboard()

" Fix problems in files.
command! -bar ALEFix :call ale#fix#Fix()
" Suggest registered functions to use for fixing problems.
command! -bar ALEFixSuggest :call ale#fix#registry#Suggest(&filetype)

" <Plug> mappings for commands
nnoremap <silent> <Plug>(ale_previous) :ALEPrevious<Return>
nnoremap <silent> <Plug>(ale_previous_wrap) :ALEPreviousWrap<Return>
nnoremap <silent> <Plug>(ale_next) :ALENext<Return>
nnoremap <silent> <Plug>(ale_next_wrap) :ALENextWrap<Return>
nnoremap <silent> <Plug>(ale_first) :ALEFirst<Return>
nnoremap <silent> <Plug>(ale_last) :ALELast<Return>
nnoremap <silent> <Plug>(ale_toggle) :ALEToggle<Return>
nnoremap <silent> <Plug>(ale_lint) :ALELint<Return>
nnoremap <silent> <Plug>(ale_detail) :ALEDetail<Return>
nnoremap <silent> <Plug>(ale_fix) :ALEFix<Return>

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
