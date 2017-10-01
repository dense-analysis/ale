" Author: w0rp <devw0rp@gmail.com>
" Description: A registry of functions for fixing things.

let s:default_registry = {
\   'add_blank_lines_for_python_control_statements': {
\       'function': 'ale#fixers#generic_python#AddLinesBeforeControlStatements',
\       'suggested_filetypes': ['python'],
\       'description': 'Add blank lines before control statements.',
\   },
\   'align_help_tags': {
\       'function': 'ale#fixers#help#AlignTags',
\       'suggested_filetypes': ['help'],
\       'description': 'Align help tags to the right margin',
\   },
\   'autopep8': {
\       'function': 'ale#fixers#autopep8#Fix',
\       'suggested_filetypes': ['python'],
\       'description': 'Fix PEP8 issues with autopep8.',
\   },
\   'prettier_standard': {
\       'function': 'ale#fixers#prettier_standard#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Apply prettier-standard to a file.',
\   },
\   'eslint': {
\       'function': 'ale#fixers#eslint#Fix',
\       'suggested_filetypes': ['javascript', 'typescript'],
\       'description': 'Apply eslint --fix to a file.',
\   },
\   'format': {
\       'function': 'ale#fixers#format#Fix',
\       'suggested_filetypes': ['elm'],
\       'description': 'Apply elm-format to a file.',
\   },
\   'isort': {
\       'function': 'ale#fixers#isort#Fix',
\       'suggested_filetypes': ['python'],
\       'description': 'Sort Python imports with isort.',
\   },
\   'prettier': {
\       'function': 'ale#fixers#prettier#Fix',
\       'suggested_filetypes': ['javascript', 'typescript', 'json', 'css', 'scss'],
\       'description': 'Apply prettier to a file.',
\   },
\   'prettier_eslint': {
\       'function': 'ale#fixers#prettier_eslint#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Apply prettier-eslint to a file.',
\   },
\   'puppetlint': {
\       'function': 'ale#fixers#puppetlint#Fix',
\       'suggested_filetypes': ['puppet'],
\       'description': 'Run puppet-lint -f on a file.',
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
\   'rubocop': {
\       'function': 'ale#fixers#rubocop#Fix',
\       'suggested_filetypes': ['ruby'],
\       'description': 'Fix ruby files with rubocop --auto-correct.',
\   },
\   'standard': {
\       'function': 'ale#fixers#standard#Fix',
\       'suggested_filetypes': ['javascript'],
\       'description': 'Fix JavaScript files using standard --fix',
\   },
\   'stylelint': {
\       'function': 'ale#fixers#stylelint#Fix',
\       'suggested_filetypes': ['css', 'sass', 'scss', 'stylus'],
\       'description': 'Fix stylesheet files using stylelint --fix.',
\   },
\   'swiftformat': {
\       'function': 'ale#fixers#swiftformat#Fix',
\       'suggested_filetypes': ['swift'],
\       'description': 'Apply SwiftFormat to a file.',
\   },
\   'phpcbf': {
\       'function': 'ale#fixers#phpcbf#Fix',
\       'suggested_filetypes': ['php'],
\       'description': 'Fix PHP files with phpcbf.',
\   },
\   'clang-format': {
\       'function': 'ale#fixers#clangformat#Fix',
\       'suggested_filetypes': ['c', 'cpp'],
\       'description': 'Fix C/C++ files with clang-format.',
\   },
\   'gofmt': {
\       'function': 'ale#fixers#gofmt#Fix',
\       'suggested_filetypes': ['go'],
\       'description': 'Fix Go files with go fmt.',
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
    let l:filetype_fixer_list = []

    for l:key in sort(keys(s:entries))
        let l:suggested_filetypes = s:entries[l:key].suggested_filetypes

        if s:ShouldSuggestForType(l:suggested_filetypes, l:type_list)
            call add(
            \   l:filetype_fixer_list,
            \   printf('%s - %s', string(l:key), s:entries[l:key].description),
            \)
        endif
    endfor

    let l:generic_fixer_list = []

    for l:key in sort(keys(s:entries))
        if empty(s:entries[l:key].suggested_filetypes)
            call add(
            \   l:generic_fixer_list,
            \   printf('%s - %s', string(l:key), s:entries[l:key].description),
            \)
        endif
    endfor

    let l:filetype_fixer_header = !empty(l:filetype_fixer_list)
    \   ? ['Try the following fixers appropriate for the filetype:', '']
    \   : []
    let l:generic_fixer_header = !empty(l:generic_fixer_list)
    \   ? ['Try the following generic fixers:', '']
    \   : []

    let l:has_both_lists = !empty(l:filetype_fixer_list) && !empty(l:generic_fixer_list)

    let l:lines =
    \   l:filetype_fixer_header
    \   + l:filetype_fixer_list
    \   + (l:has_both_lists ? [''] : [])
    \   + l:generic_fixer_header
    \   + l:generic_fixer_list

    if empty(l:lines)
        let l:lines = ['There is nothing in the registry to suggest.']
    else
        let l:lines += ['', 'See :help ale-fix-configuration']
    endif

    let l:lines += ['', 'Press q to close this window']

    new +set\ filetype=ale-fix-suggest
    call setline(1, l:lines)
    setlocal nomodified
    setlocal nomodifiable
endfunction
