" Author: Vivian De Smedt <vds2212@gmail.com>, Adrian Vollmer <computerfluesterer@protonmail.com>
" Description: Adds support for djlint
"
function! ale#handlers#djlint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'html_djlint_executable')
endfunction

function! ale#handlers#djlint#GetCommand(buffer) abort
    let l:executable = ale#handlers#djlint#GetExecutable(a:buffer)

    let l:options = ale#Var(a:buffer, 'html_djlint_options')

    let l:profile = ''
    let l:filetypes = split(getbufvar(a:buffer, '&filetype'), '\.')

    " Append the --profile flag depending on the current filetype (unless it's
    " already set in g:html_djlint_options).
    if match(l:options, '--profile') == -1
        let l:djlint_profiles = {
        \    'html': 'html',
        \    'htmldjango': 'django',
        \    'jinja': 'jinja',
        \    'nunjucks': 'nunjucks',
        \    'handlebars': 'handlebars',
        \    'gohtmltmpl': 'golang',
        \    'htmlangular': 'angular',
        \}

        for l:filetype in l:filetypes
            if has_key(l:djlint_profiles, l:filetype)
                let l:profile = l:djlint_profiles[l:filetype]
                break
            endif
        endfor
    endif

    if !empty(l:profile)
        let l:options = (!empty(l:options) ? l:options . ' ' : '') . '--profile ' . l:profile
    endif

    return ale#Escape(l:executable)
    \ . ale#Pad(l:options) . ' %s'
endfunction

function! ale#handlers#djlint#Handle(buffer, lines) abort
    let l:output = []
    let l:pattern = '\v^([A-Z]\d+) (\d+):(\d+) (.*)$'
    let l:i = 0

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:i += 1
        let l:item = {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'vcol': 1,
        \   'text': l:match[4],
        \   'code': l:match[1],
        \   'type': 'W',
        \}
        call add(l:output, l:item)
    endfor

    return l:output
endfunction
