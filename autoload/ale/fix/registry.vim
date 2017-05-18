" Author: w0rp <devw0rp@gmail.com>
" Description: A registry of functions for fixing things.

let s:default_registry = {
\   'eslint': {
\       'function': 'ale#handlers#eslint#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': '',
\   },
\}

" Reset the function registry to the default entries.
function! ale#fix#registry#ResetToDefaults() abort
    let s:entries = deepcopy(s:default_registry)
endfunction

" Set up entries now.
call ale#fix#registry#ResetToDefaults()

" Add a function for fixing problems to the registry.
function! ale#fix#registry#Add(name, func, filetypes, desc) abort
    if type(a:name) != type('')
        throw '''name'' must be a String'
    endif

    if type(a:func) != type('')
        throw '''func'' must be a String'
    endif

    if type(a:filetypes) != type([])
        throw '''filetypes'' must be a List'
    endif

    for l:type in a:filetypes
        if type(l:type) != type('')
            throw 'Each entry of ''filetypes'' must be a String'
        endif
    endfor

    if type(a:desc) != type('')
        throw '''desc'' must be a String'
    endif

    let s:entries[a:name] = {
    \   'function': a:func,
    \   'suggested_filetypes': a:filetypes,
    \   'description': a:desc,
    \}
endfunction

" Get a function from the registry by its short name.
function! ale#fix#registry#GetFunc(name) abort
    return get(s:entries, a:name, {'function': ''}).function
endfunction
