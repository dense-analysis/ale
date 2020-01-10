" Author: Derek P Sifford <dereksifford@gmail.com>
" Description: Fixer for C, C++, C#, ObjectiveC, D, Java, Pawn, and VALA.

call ale#Set('c_uncrustify_executable', 'uncrustify')
call ale#Set('all_uncrustify_options', '')
call ale#Set('c_uncrustify_options', '')
call ale#Set('cpp_uncrustify_options', '')
call ale#Set('cs_uncrustify_options', '')
call ale#Set('objc_uncrustify_options', '')
call ale#Set('d_uncrustify_options', '')
call ale#Set('java_uncrustify_options', '')
call ale#Set('pawn_uncrustify_options', '')
call ale#Set('vala_uncrustify_options', '')

function! ale#fixers#uncrustify#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'c_uncrustify_executable')
    let ft_options = ale#Var(a:buffer, getbufvar(a:buffer, '&filetype') . '_uncrustify_options')
    let all_options = ale#Var(a:buffer, 'all_uncrustify_options')
    if empty(all_options)
        let l:options = ft_options
    else
        let l:options = all_options . ' ' . ft_options
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' --no-backup'
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \}
endfunction
