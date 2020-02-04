" Author: Derek P Sifford <dereksifford@gmail.com>
" Description: Fixer for C, C++, C#, ObjectiveC, D, Java, Pawn, and VALA.

call ale#Set('uncrustify_per_type', 0)
call ale#Set('uncrustify_force_filetype', 0)
call ale#Set('uncrustify_global_options', '')
call ale#Set('uncrustify_executable', 'uncrustify')
call ale#Set('c_uncrustify_options', '')
call ale#Set('cpp_uncrustify_options', '')
call ale#Set('cs_uncrustify_options', '')
call ale#Set('objc_uncrustify_options', '')
call ale#Set('d_uncrustify_options', '')
call ale#Set('java_uncrustify_options', '')
call ale#Set('pawn_uncrustify_options', '')
call ale#Set('vala_uncrustify_options', '')

function! ale#fixers#uncrustify#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'uncrustify_executable')
    let ft = getbufvar(a:buffer, '&filetype')
    if empty(ft)
        let ft_options = ''
    else
        let ft_options = ale#Var(a:buffer, ft . '_uncrustify_options')
endif
    let all_options = ale#Var(a:buffer, 'uncrustify_global_options')

    if !ale#Var(a:buffer, 'uncrustify_per_type')
        let ft_options = ''
        " For backwards compatibility, use C options if
        " all_options is empty and not using per_type
        if empty(all_options)
            let all_options = ale#Var(a:buffer, 'c_uncrustify_options')
        endif
    endif

    if empty(all_options)
        let l:options = ft_options
    elseif empty(ft_options)
        let l:options = all_options
    else
        "Put ft_options before all_options since uncrustify uses the first
        "occurrence of each flag
        let l:options = ft_options . ' ' . all_options
    endif

    if ale#Var(a:buffer, 'uncrustify_force_filetype')
        let l:options = '-l ' . ft . (empty(l:options) ? '' : ' ' . l:options)
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' --no-backup'
    \       . (empty(l:options) ? '' : ' ' . ale#Escape(l:options))
    \}
endfunction
