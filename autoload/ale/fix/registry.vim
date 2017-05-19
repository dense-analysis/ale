" Author: w0rp <devw0rp@gmail.com>
" Description: A registry of functions for fixing things.

let s:default_registry = {
\   'autopep8': {
\       'function': 'ale#handlers#python#AutoPEP8',
\       'suggested_filetypes': ['python'],
\       'description': 'Fix PEP8 issues with autopep8.',
\   },
\   'eslint': {
\       'function': 'ale#handlers#eslint#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Apply eslint --fix to a file.',
\   },
\   'isort': {
\       'function': 'ale#handlers#python#ISort',
\       'suggested_filetypes': ['python'],
\       'description': 'Sort Python imports with isort.',
\   },
\   'remove_trailing_lines': {
\       'function': 'ale#fix#generic#RemoveTrailingBlankLines',
\       'suggested_filetypes': [],
\       'description': 'Remove all blank lines at the end of a file.',
\   },
\   'yapf': {
\       'function': 'ale#handlers#python#YAPF',
\       'suggested_filetypes': ['python'],
\       'description': 'Fix Python files with yapf.',
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
