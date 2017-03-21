" Author: w0rp <devw0rp@gmail.com>
" Description: Primary code path for the plugin
"   Manages execution of linters when requested by autocommands

let s:lint_timer = -1
let s:should_lint_file_for_buffer = {}

" A function for checking various conditions whereby ALE just shouldn't
" attempt to do anything, say if particular buffer types are open in Vim.
function! ale#ShouldDoNothing() abort
    " Do nothing for blacklisted files
    " OR if ALE is running in the sandbox
    return index(g:ale_filetype_blacklist, &filetype) >= 0
    \   || ale#util#InSandbox()
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
        let s:lint_timer = timer_start(a:delay, function('ale#Lint'))
    else
        call ale#Lint()
    endif
endfunction

function! ale#Lint(...) abort
    if ale#ShouldDoNothing()
        return
    endif

    let l:buffer = bufnr('%')
    let l:linters = ale#linter#Get(&filetype)
    let l:should_lint_file = 0

    " Check if we previously requested checking the file.
    if has_key(s:should_lint_file_for_buffer, l:buffer)
        unlet s:should_lint_file_for_buffer[l:buffer]
        let l:should_lint_file = 1
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

    for l:linter in l:linters
        call ale#engine#Invoke(l:buffer, l:linter)
    endfor
endfunction

" Reset flags indicating that files should be checked for all buffers.
function! ale#ResetLintFileMarkers() abort
    let s:should_lint_file_for_buffer = {}
endfunction
