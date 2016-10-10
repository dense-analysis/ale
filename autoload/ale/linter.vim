let s:linters = {}

function! ale#linter#define(filetype, linter) abort
    if !has_key(s:linters, a:filetype)
        let s:linters[a:filetype] = []
    endif

    let new_linter = {
    \   'name': a:linter.name,
    \   'callback': a:linter.callback,
    \}

    if has_key(a:linter, 'executable_callback')
        let new_linter.executable_callback = a:linter.executable_callback
    else
        let new_linter.executable = a:linter.executable
    endif

    if has_key(a:linter, 'command_callback')
        let new_linter.command_callback = a:linter.command_callback
    else
        let new_linter.command = a:linter.command
    endif

    if has_key(a:linter, 'output_stream')
        let new_linter.output_stream = a:linter.output_stream
    else
        let new_linter.output_stream = 'stdout'
    endif

    " TODO: Assert the value of the output_stream to be something sensible.

    call add(s:linters[a:filetype], new_linter)
endfunction

function! ale#linter#get(filetype) abort
    if a:filetype ==# ''
        " Empty filetype? Nothing to be done about that.
        return []
    endif

    if has_key(s:linters, a:filetype)
        " We already loaded a linter, great!
        return s:linters[a:filetype]
    endif

    if has_key(g:ale_linters, a:filetype)
        " Filter loaded linters according to list of linters specified in option.
        for linter in g:ale_linters[a:filetype]
            execute 'runtime! ale_linters/' . a:filetype . '/' . linter . '.vim'
        endfor
    else
        execute 'runtime! ale_linters/' . a:filetype . '/*.vim'
    endif

    if has_key(s:linters, a:filetype)
        " If we found a linter, return it now.
        return s:linters[a:filetype]
    else
        " If we couldn't load a linter, blacklist it in the future.
        let g:ale_linters[a:filetype] = []
        return []
    endif
endfunction
