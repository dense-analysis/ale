" Author: w0rp <devw0rp@gmail.com>
" Description: Linter registration and lazy-loading
"   Retrieves linters as requested by the engine, loading them if needed.

let s:linters = {}
let s:folder_aliases = {
    \ 'javascript.jsx': 'javascript',
    \ 'csh': 'sh',
    \ 'zsh': 'sh'
\}

function! ale#linter#Define(...) abort
    let l:linter = a:000[-1]
    let l:filetypes = a:000[:-2]

    let l:new_linter = {
    \   'name': l:linter.name,
    \   'callback': l:linter.callback,
    \}

    if has_key(l:linter, 'executable_callback')
        let l:new_linter.executable_callback = l:linter.executable_callback
    else
        let l:new_linter.executable = l:linter.executable
    endif

    if has_key(l:linter, 'command_callback')
        let l:new_linter.command_callback = l:linter.command_callback
    else
        let l:new_linter.command = l:linter.command
    endif

    if has_key(l:linter, 'output_stream')
        let l:new_linter.output_stream = l:linter.output_stream
    else
        let l:new_linter.output_stream = 'stdout'
    endif

    " TODO: Assert the value of the output_stream to be something sensible.

    for l:filetype in l:filetypes
        if !has_key(s:linters, l:filetype)
            let s:linters[l:filetype] = []
        endif
        call add(s:linters[l:filetype], l:new_linter)
    endfor
endfunction

function! ale#linter#Get(filetype) abort
    if a:filetype ==# ''
        " Empty filetype? Nothing to be done about that.
        return []
    endif

    if has_key(s:linters, a:filetype)
        " We already loaded a linter, great!
        return s:linters[a:filetype]
    endif

    if has_key(s:folder_aliases, a:filetype)
        " We have an alias for this filetype, so just load that.
        let l:folder = s:folder_aliases[a:filetype]
    else
        let l:folder = a:filetype
    endif

    if has_key(g:ale_linters, a:filetype)
        " Filter loaded linters according to list of linters specified in option.
        for l:linter in g:ale_linters[a:filetype]
            execute 'runtime! ale_linters/' . l:folder . '/' . l:linter . '.vim'
        endfor
    else
        execute 'runtime! ale_linters/' . l:folder . '/*.vim'
    endif

    if !has_key(s:linters, a:filetype)
        " If we couldn't load any linters, let everyone know.
        let s:linters[a:filetype] = []
    endif

    return s:linters[a:filetype]
endfunction
