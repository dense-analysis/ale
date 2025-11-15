:scriptencoding utf-8

call ale#Set('markdownlint_executable', 'markdownlint')
call ale#Set('markdownlint_options', '--fix')

function! ale#fixers#markdownlint#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'markdownlint_executable')
    let l:options = ale#Var(a:buffer, 'markdownlint_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' ' . l:options,
    \}
endfunction

