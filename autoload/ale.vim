" Author: w0rp <devw0rp@gmail.com>, David Alexander <opensource@thelonelyghost.com>
" Description: Primary code path for the plugin
"   Manages execution of linters when requested by autocommands

let s:lint_timer = -1
let s:queued_buffer_number = -1
let s:should_lint_file_for_buffer = {}

" Return 1 if a file is too large for ALE to handle.
function! ale#FileTooLarge() abort
    let l:max = ale#Var(bufnr(''), 'maximum_file_size')

    return l:max > 0 ? (line2byte(line('$') + 1) > l:max) : 0
endfunction

" A function for checking various conditions whereby ALE just shouldn't
" attempt to do anything, say if particular buffer types are open in Vim.
function! ale#ShouldDoNothing() abort
    " Do nothing for blacklisted files
    " OR if ALE is running in the sandbox
    return index(g:ale_filetype_blacklist, &filetype) >= 0
    \   || (exists('*getcmdwintype') && !empty(getcmdwintype()))
    \   || ale#util#InSandbox()
    \   || !ale#Var(bufnr(''), 'enabled')
    \   || ale#FileTooLarge()
endfunction

" (delay, [linting_flag])
function! ale#Queue(delay, ...) abort
    if len(a:0) > 1
        throw 'too many arguments!'
    endif

    " Default linting_flag to ''
    let l:linting_flag = get(a:000, 0, '')

    if l:linting_flag !=# '' && l:linting_flag !=# 'lint_file'
        throw "linting_flag must be either '' or 'lint_file'"
    endif

    if ale#ShouldDoNothing()
        return
    endif

    " Remember that we want to check files for this buffer.
    " We will remember this until we finally run the linters, via any event.
    if l:linting_flag ==# 'lint_file'
        let s:should_lint_file_for_buffer[bufnr('%')] = 1
    endif

    if s:lint_timer != -1
        call timer_stop(s:lint_timer)
        let s:lint_timer = -1
    endif

    let l:linters = ale#linter#Get(&filetype)
    if len(l:linters) == 0
        " There are no linters to lint with, so stop here.
        return
    endif

    if a:delay > 0
        let s:queued_buffer_number = bufnr('%')
        let s:lint_timer = timer_start(a:delay, function('ale#Lint'))
    else
        call ale#Lint()
    endif
endfunction

function! ale#Lint(...) abort
    if ale#ShouldDoNothing()
        return
    endif

    " Get the buffer number linting was queued for.
    " or else take the current one.
    let l:buffer = len(a:0) > 1 && a:1 == s:lint_timer
    \   ? s:queued_buffer_number
    \   : bufnr('%')

    " Use the filetype from the buffer
    let l:linters = ale#linter#Get(getbufvar(l:buffer, '&filetype'))
    let l:should_lint_file = 0

    " Check if we previously requested checking the file.
    if has_key(s:should_lint_file_for_buffer, l:buffer)
        unlet s:should_lint_file_for_buffer[l:buffer]
        " Lint files if they exist.
        let l:should_lint_file = filereadable(expand('#' . l:buffer . ':p'))
    endif

    " Initialise the buffer information if needed.
    call ale#engine#InitBufferInfo(l:buffer)

    " Clear the new loclist again, so we will work with all new items.
    let g:ale_buffer_info[l:buffer].new_loclist = []

    if l:should_lint_file
        " Clear loclist items for files if we are checking files again.
        let g:ale_buffer_info[l:buffer].lint_file_loclist = []
    else
        " Otherwise, don't run any `lint_file` linters
        " We will continue running any linters which are currently checking
        " the file, and the items will be mixed together with any new items.
        call filter(l:linters, '!v:val.lint_file')
    endif

    call ale#engine#StopCurrentJobs(l:buffer, l:should_lint_file)

    for l:linter in l:linters
        call ale#engine#Invoke(l:buffer, l:linter)
    endfor
endfunction

" Reset flags indicating that files should be checked for all buffers.
function! ale#ResetLintFileMarkers() abort
    let s:should_lint_file_for_buffer = {}
endfunction

let g:ale_has_override = get(g:, 'ale_has_override', {})

" Call has(), but check a global Dictionary so we can force flags on or off
" for testing purposes.
function! ale#Has(feature) abort
    return get(g:ale_has_override, a:feature, has(a:feature))
endfunction

" Given a buffer number and a variable name, look for that variable in the
" buffer scope, then in global scope. If the name does not exist in the global
" scope, an exception will be thrown.
"
" Every variable name will be prefixed with 'ale_'.
function! ale#Var(buffer, variable_name) abort
    let l:nr = str2nr(a:buffer)
    let l:full_name = 'ale_' . a:variable_name

    if bufexists(l:nr)
        let l:vars = getbufvar(l:nr, '')
    elseif has_key(g:, 'ale_fix_buffer_data')
        let l:vars = get(g:ale_fix_buffer_data, l:nr, {'vars': {}}).vars
    else
        let l:vars = {}
    endif

    return get(l:vars, l:full_name, g:[l:full_name])
endfunction

" Initialize a variable with a default value, if it isn't already set.
"
" Every variable name will be prefixed with 'ale_'.
function! ale#Set(variable_name, default) abort
    let l:full_name = 'ale_' . a:variable_name
    let l:value = get(g:, l:full_name, a:default)
    let g:[l:full_name] = l:value

    return l:value
endfunction

" Escape a string suitably for each platform.
" shellescape does not work on Windows.
function! ale#Escape(str) abort
    if fnamemodify(&shell, ':t') ==? 'cmd.exe'
        " If the string contains spaces, it will be surrounded by quotes.
        " Otherwise, special characters will be escaped with carets (^).
        return substitute(
        \   a:str =~# ' '
        \       ?  '"' .  substitute(a:str, '"', '""', 'g') . '"'
        \       : substitute(a:str, '\v([&|<>^])', '^\1', 'g'),
        \   '%',
        \   '%%',
        \   'g',
        \)
    endif

    return shellescape (a:str)
endfunction
