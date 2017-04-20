" Author: w0rp <devw0rp@gmail.com>
" Description: Linter registration and lazy-loading
"   Retrieves linters as requested by the engine, loading them if needed.

let s:linters = {}

" Default filetype aliaes.
" The user defined aliases will be merged with this Dictionary.
let s:default_ale_linter_aliases = {
\   'Dockerfile': 'dockerfile',
\   'csh': 'sh',
\   'plaintex': 'tex',
\   'systemverilog': 'verilog',
\   'zsh': 'sh',
\}

" Default linters to run for particular filetypes.
" The user defined linter selections will be merged with this Dictionary.
"
" No linters are used for plaintext files by default.
"
" Only cargo is enabled for Rust by default.
" rpmlint is disabled by default because it can result in code execution.
let s:default_ale_linters = {
\   'csh': ['shell'],
\   'go': ['go build', 'gofmt', 'golint', 'gosimple', 'go vet', 'staticcheck'],
\   'help': [],
\   'rust': ['cargo'],
\   'spec': [],
\   'text': [],
\   'zsh': ['shell'],
\}

" Testing/debugging helper to unload all linters.
function! ale#linter#Reset() abort
    let s:linters = {}
endfunction

function! s:IsCallback(value) abort
    return type(a:value) == type('') || type(a:value) == type(function('type'))
endfunction

function! s:IsBoolean(value) abort
    return type(a:value) == type(0) && (a:value == 0 || a:value == 1)
endfunction

function! ale#linter#PreProcess(linter) abort
    if type(a:linter) != type({})
        throw 'The linter object must be a Dictionary'
    endif

    let l:obj = {
    \   'name': get(a:linter, 'name'),
    \   'callback': get(a:linter, 'callback'),
    \}

    if type(l:obj.name) != type('')
        throw '`name` must be defined to name the linter'
    endif

    if !s:IsCallback(l:obj.callback)
        throw '`callback` must be defined with a callback to accept output'
    endif

    if has_key(a:linter, 'executable_callback')
        let l:obj.executable_callback = a:linter.executable_callback

        if !s:IsCallback(l:obj.executable_callback)
            throw '`executable_callback` must be a callback if defined'
        endif
    elseif has_key(a:linter, 'executable')
        let l:obj.executable = a:linter.executable

        if type(l:obj.executable) != type('')
            throw '`executable` must be a string if defined'
        endif
    else
        throw 'Either `executable` or `executable_callback` must be defined'
    endif

    if has_key(a:linter, 'command_chain')
        let l:obj.command_chain = a:linter.command_chain

        if type(l:obj.command_chain) != type([])
            throw '`command_chain` must be a List'
        endif

        if empty(l:obj.command_chain)
            throw '`command_chain` must contain at least one item'
        endif

        let l:link_index = 0

        for l:link in l:obj.command_chain
            let l:err_prefix = 'The `command_chain` item ' . l:link_index . ' '

            if !s:IsCallback(get(l:link, 'callback'))
                throw l:err_prefix . 'must define a `callback` function'
            endif

            if has_key(l:link, 'output_stream')
                if type(l:link.output_stream) != type('')
                \|| index(['stdout', 'stderr', 'both'], l:link.output_stream) < 0
                    throw l:err_prefix . '`output_stream` flag must be '
                    \   . "'stdout', 'stderr', or 'both'"
                endif
            endif

            if has_key(l:link, 'read_buffer') && !s:IsBoolean(l:link.read_buffer)
                throw l:err_prefix . 'value for `read_buffer` must be `0` or `1`'
            endif

            let l:link_index += 1
        endfor
    elseif has_key(a:linter, 'command_callback')
        let l:obj.command_callback = a:linter.command_callback

        if !s:IsCallback(l:obj.command_callback)
            throw '`command_callback` must be a callback if defined'
        endif
    elseif has_key(a:linter, 'command')
        let l:obj.command = a:linter.command

        if type(l:obj.command) != type('')
            throw '`command` must be a string if defined'
        endif
    else
        throw 'Either `command`, `executable_callback`, `command_chain` '
        \   . 'must be defined'
    endif

    if (
    \   has_key(a:linter, 'command')
    \   + has_key(a:linter, 'command_chain')
    \   + has_key(a:linter, 'command_callback')
    \) > 1
        throw 'Only one of `command`, `command_callback`, or `command_chain` '
        \   . 'should be set'
    endif

    let l:obj.output_stream = get(a:linter, 'output_stream', 'stdout')

    if type(l:obj.output_stream) != type('')
    \|| index(['stdout', 'stderr', 'both'], l:obj.output_stream) < 0
        throw "`output_stream` must be 'stdout', 'stderr', or 'both'"
    endif

    " An option indicating that this linter should only be run against the
    " file on disk.
    let l:obj.lint_file = get(a:linter, 'lint_file', 0)

    if !s:IsBoolean(l:obj.lint_file)
        throw '`lint_file` must be `0` or `1`'
    endif

    " An option indicating that the buffer should be read.
    let l:obj.read_buffer = get(a:linter, 'read_buffer', !l:obj.lint_file)

    if !s:IsBoolean(l:obj.read_buffer)
        throw '`read_buffer` must be `0` or `1`'
    endif

    if l:obj.lint_file && l:obj.read_buffer
        throw 'Only one of `lint_file` or `read_buffer` can be `1`'
    endif

    return l:obj
endfunction

function! ale#linter#Define(filetype, linter) abort
    if !has_key(s:linters, a:filetype)
        let s:linters[a:filetype] = []
    endif

    let l:new_linter = ale#linter#PreProcess(a:linter)

    call add(s:linters[a:filetype], l:new_linter)
endfunction

function! ale#linter#GetAll(filetypes) abort
    let l:combined_linters = []

    for l:filetype in a:filetypes
        " Load linter defintions from files if we haven't loaded them yet.
        if !has_key(s:linters, l:filetype)
            execute 'silent! runtime! ale_linters/' . l:filetype . '/*.vim'

            " Always set an empty List for the loaded linters if we don't find
            " any. This will prevent us from executing the runtime command
            " many times, redundantly.
            if !has_key(s:linters, l:filetype)
                let s:linters[l:filetype] = []
            endif
        endif

        call extend(l:combined_linters, get(s:linters, l:filetype, []))
    endfor

    return l:combined_linters
endfunction

function! ale#linter#ResolveFiletype(original_filetype) abort
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

    if type(l:filetype) != type([])
        return [l:filetype]
    endif

    return l:filetype
endfunction

function! ale#linter#Get(original_filetypes) abort
    let l:combined_linters = []

    " Handle dot-seperated filetypes.
    for l:original_filetype in split(a:original_filetypes, '\.')
        let l:filetype = ale#linter#ResolveFiletype(l:original_filetype)

        " Try and get a list of linters to run, using the original file type,
        " not the aliased filetype. We have some linters to limit by default,
        " and users may define their own list of linters to run.
        let l:linter_names = get(
        \   g:ale_linters,
        \   l:original_filetype,
        \   get(
        \       s:default_ale_linters,
        \       l:original_filetype,
        \       'all'
        \   )
        \)

        let l:all_linters = ale#linter#GetAll(l:filetype)
        let l:filetype_linters = []

        if type(l:linter_names) == type('') && l:linter_names ==# 'all'
            let l:filetype_linters = l:all_linters
        elseif type(l:linter_names) == type([])
            " Select only the linters we or the user has specified.
            for l:linter in l:all_linters
                if index(l:linter_names, l:linter.name) >= 0
                    call add(l:filetype_linters, l:linter)
                endif
            endfor
        endif

        call extend(l:combined_linters, l:filetype_linters)
    endfor

    return l:combined_linters
endfunction
