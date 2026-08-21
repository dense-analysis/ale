:scriptencoding utf-8

call ale#Set('markdownlint_executable', 'markdownlint')
call ale#Set('markdownlint_options', '')

function! ale#fixers#markdownlint#FixFor(buffer, name) abort
    let l:executable = ale#Var(a:buffer, a:name . '_executable')
    let l:options = ale#Var(a:buffer, a:name . '_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' --fix'
    \       . ale#Pad(l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction

function! ale#fixers#markdownlint#Fix(buffer) abort
    return ale#fixers#markdownlint#FixFor(a:buffer, 'markdownlint')
endfunction

