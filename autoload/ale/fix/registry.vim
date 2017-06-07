" Author: w0rp <devw0rp@gmail.com>
" Description: A registry of functions for fixing things.

let s:default_registry = {
\   'add_blank_lines_for_python_control_statements': {
\       'function': 'ale#fixers#generic_python#AddLinesBeforeControlStatements',
\       'suggested_filetypes': ['python'],
\       'description': 'Add blank lines before control statements.',
\   },
\   'autopep8': {
\       'function': 'ale#fixers#autopep8#Fix',
\       'suggested_filetypes': ['python'],
\       'description': 'Fix PEP8 issues with autopep8.',
\   },
\   'eslint': {
\       'function': 'ale#fixers#eslint#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Apply eslint --fix to a file.',
\   },
\   'isort': {
\       'function': 'ale#fixers#isort#Fix',
\       'suggested_filetypes': ['python'],
\       'description': 'Sort Python imports with isort.',
\   },
\   'prettier': {
\       'function': 'ale#fixers#prettier#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Apply prettier to a file.',
\   },
\   'prettier_eslint': {
\       'function': 'ale#fixers#prettier_eslint#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Apply prettier-eslint to a file.',
\   },
\   'remove_trailing_lines': {
\       'function': 'ale#fixers#generic#RemoveTrailingBlankLines',
\       'suggested_filetypes': [],
\       'description': 'Remove all blank lines at the end of a file.',
\   },
\   'yapf': {
\       'function': 'ale#fixers#yapf#Fix',
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

" Remove everything from the registry, useful for tests.
function! ale#fix#registry#Clear() abort
    let s:entries = {}
endfunction

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

function! s:ShouldSuggestForType(suggested_filetypes, type_list) abort
    for l:type in a:type_list
        if index(a:suggested_filetypes, l:type) >= 0
            return 1
        endif
    endfor

    return 0
endfunction

" Suggest functions to use from the registry.
function! ale#fix#registry#Suggest(filetype) abort
    let l:type_list = split(a:filetype, '\.')
    let l:first_for_filetype = 1
    let l:first_generic = 1

    for l:key in sort(keys(s:entries))
        let l:suggested_filetypes = s:entries[l:key].suggested_filetypes

        if s:ShouldSuggestForType(l:suggested_filetypes, l:type_list)
            if l:first_for_filetype
                let l:first_for_filetype = 0
                echom 'Try the following fixers appropriate for the filetype:'
                echom ''
            endif

            echom printf('%s - %s', string(l:key), s:entries[l:key].description)
        endif
    endfor


    for l:key in sort(keys(s:entries))
        if empty(s:entries[l:key].suggested_filetypes)
            if l:first_generic
                if !l:first_for_filetype
                    echom ''
                endif

                let l:first_generic = 0
                echom 'Try the following generic fixers:'
                echom ''
            endif

            echom printf('%s - %s', string(l:key), s:entries[l:key].description)
        endif
    endfor

    if l:first_for_filetype && l:first_generic
        echom 'There is nothing in the registry to suggest.'
    else
        echom ''
        echom 'See :help ale-fix-configuration'
    endif
endfunction
