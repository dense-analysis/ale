" Author: w0rp <devw0rp@gmail.com>
" Description: Primary code path for the plugin
"   Manages execution of linters when requested by autocommands

let s:lint_timer = -1
let s:should_lint_file = 0

" A function for checking various conditions whereby ALE just shouldn't
" attempt to do anything, say if particular buffer types are open in Vim.
function! ale#ShouldDoNothing() abort
    " Do nothing for blacklisted files
    " OR if ALE is running in the sandbox
    return index(g:ale_filetype_blacklist, &filetype) >= 0
    \   || ale#util#InSandbox()
endfunction

" (delay, [run_file_linters])
function! ale#Queue(delay, ...) abort
    if len(a:0) > 1
        throw 'too many arguments!'
    endif

    let l:a1 = len(a:0) > 1 ? a:1 : 0

    if type(l:a1) != type(1) || (l:a1 != 0 && l:a1 != 1)
        throw 'The lint_file argument must be a Number which is either 0 or 1!'
    endif

    if ale#ShouldDoNothing()
        return
    endif

    " Remember the event used for linting.
    let s:should_lint_file = l:a1

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

    " Initialise the buffer information if needed.
    call ale#engine#InitBufferInfo(l:buffer)

    " Clear the new loclist again, so we will work with all new items.
    let g:ale_buffer_info[l:buffer].new_loclist = []

    for l:linter in l:linters
        call ale#engine#Invoke(l:buffer, l:linter)
    endfor
endfunction
