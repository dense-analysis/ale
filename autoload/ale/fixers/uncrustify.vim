" Author: Derek P Sifford <dereksifford@gmail.com>
" Description: Fixer for C, C++, C#, ObjectiveC, D, Java, Pawn, and VALA.

call ale#Set('c_uncrustify_executable', 'uncrustify')
call ale#Set('c_uncrustify_force_filetype', 0)
call ale#Set('c_uncrustify_global_options', '')
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
    let ft = getbufvar(a:buffer, '&filetype')
    let ft_options = ale#Var(a:buffer, ft . '_uncrustify_options')
    let all_options = ale#Var(a:buffer, 'c_uncrustify_global_options')
    let l:options = ft_options

    "Put ft_options before all_options since uncrustify uses the first
    "occurrence of each flag
    if empty(ft_options)
        let l:options = all_options
    elseif empty(all_options)
        let l:options = ''
    else
        let l:options = ft_options . ' ' . all_options
    endif

    if ale#Var(a:buffer, 'c_uncrustify_force_filetype')
        let l:options = '-l ' . ft . (empty(l:options) ? '' : ' ' . l:options)
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' --no-backup'
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \}
endfunction
