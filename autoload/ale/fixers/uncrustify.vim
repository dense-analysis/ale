" Author: Derek P Sifford <dereksifford@gmail.com>
" Description: Fixer for C, C++, C#, ObjectiveC, D, Java, Pawn, and VALA.

call ale#Set('c_uncrustify_executable', 'uncrustify')
call ale#Set('c_uncrustify_options', '')
call ale#Set('c_uncrustify_language_mappings', {
\   'c'      : 'c',
\   'cpp'    : 'cpp',
\   'objc'   : 'oc',
\   'objcpp' : 'oc+',
\   'cs'     : 'cs',
\   'java'   : 'java'
\ })

function! ale#fixers#uncrustify#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'c_uncrustify_executable')
    let l:options = ale#Var(a:buffer, 'c_uncrustify_options')
    let l:language_mappings = ale#Var(a:buffer, 'c_uncrustify_language_mappings')

    if type(l:language_mappings) is v:t_dict && has_key(l:language_mappings, &filetype)
        let l:options = l:options
        \   . ' -l ' . l:language_mappings[&filetype]
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' --no-backup'
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \}
endfunction
