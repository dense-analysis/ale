" Author: Adrian Vollmer (computerfluesterer@protonmail.com)
" Description: HTML template formatter using `djlint --reformat`

call ale#Set('html_djlint_executable', 'djlint')
call ale#Set('html_djlint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('html_djlint_options', '')

function! ale#fixers#djlint#Fix(buffer) abort
    let l:executable = ale#python#FindExecutable(
    \   a:buffer,
    \   'html_djlint',
    \   ['djlint']
    \)

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

    return {
    \   'command': ale#Escape(l:executable) . ' --reformat ' . l:options . ' -',
    \}
endfunction
