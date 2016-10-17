" Author: w0rp <devw0rp@gmail.com>
" Description: Linter registration and lazy-loading
"   Retrieves linters as requested by the engine, loading them if needed.

let s:linters = {}

" Default filetype aliaes.
" The user defined aliases will be merged with this Dictionary.
let s:default_ale_linter_aliases = {
\   'javascript.jsx': 'javascript',
\   'zsh': 'sh',
\   'csh': 'sh',
\}

" Default linters to run for particular filetypes.
" The user defined linter selections will be merged with this Dictionary.
let s:default_ale_linters = {
\   'zsh': ['shell'],
\   'csh': ['shell'],
\}

function! ale#linter#Define(filetype, linter) abort
    if !has_key(s:linters, a:filetype)
        let s:linters[a:filetype] = []
    endif

    let l:new_linter = {
    \   'name': a:linter.name,
    \   'callback': a:linter.callback,
    \}

    if has_key(a:linter, 'executable_callback')
        let l:new_linter.executable_callback = a:linter.executable_callback
    else
        let l:new_linter.executable = a:linter.executable
    endif

    if has_key(a:linter, 'command_callback')
        let l:new_linter.command_callback = a:linter.command_callback
    else
        let l:new_linter.command = a:linter.command
    endif

    if has_key(a:linter, 'output_stream')
        let l:new_linter.output_stream = a:linter.output_stream
    else
        let l:new_linter.output_stream = 'stdout'
    endif

    " TODO: Assert the value of the output_stream to be something sensible.

    call add(s:linters[a:filetype], l:new_linter)
endfunction

function! s:LoadLinters(filetype) abort
    if a:filetype ==# ''
        " Empty filetype? Nothing to be done about that.
        return []
    endif

    if has_key(s:linters, a:filetype)
        " We already loaded the linter files for this filetype, so stop here.
        return s:linters[a:filetype]
    endif

    " Load all linters for a given filetype.
    execute 'silent! runtime! ale_linters/' . a:filetype . '/*.vim'

    if !has_key(s:linters, a:filetype)
        " If we couldn't load any linters, let everyone know.
        let s:linters[a:filetype] = []
    endif

    return s:linters[a:filetype]
endfunction

function! ale#linter#Get(original_filetype) abort
    " Try and get an aliased file type either from the user's Dictionary, or
    " our default Dictionary, otherwise use the filetype as-is.
    let l:filetype = get(
    \   g:ale_linter_aliases,
    \   a:original_filetype,
    \   get(
    \       s:default_ale_linter_aliases,
    \       a:original_filetype,
    \       a:original_filetype
    \   )
    \)

    " Try and get a list of linters to run, using the original file type,
    " not the aliased filetype. We have some linters to limit by default,
    " and users may define their own list of linters to run.
    let l:linter_names = get(
    \   g:ale_linters,
    \   a:original_filetype,
    \   get(
    \       s:default_ale_linters,
    \       a:original_filetype,
    \       'all'
    \   )
    \)

    let l:all_linters = s:LoadLinters(l:filetype)
    let l:combined_linters = []

    if type(l:linter_names) == type('') && l:linter_names ==# 'all'
        let l:combined_linters = l:all_linters
    elseif type(l:linter_names) == type([])
        " Select only the linters we or the user has specified.
        for l:linter in l:all_linters
            if index(l:linter_names, l:linter.name) >= 0
                call add(l:combined_linters, l:linter)
            endif
        endfor
    endif

    return l:combined_linters
endfunction
