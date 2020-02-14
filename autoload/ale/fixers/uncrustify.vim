" Author: Derek P Sifford <dereksifford@gmail.com>,
"         Alexander French <afrench17@gmail.com>
" Description: Fixer for C, C++, C#, ObjectiveC, D, Java, Pawn, and VALA.

call ale#Set('uncrustify_vim_filetype', 1)
call ale#Set('uncrustify_global_options', '')
call ale#Set('uncrustify_executable', 'uncrustify')
call ale#Set('uncrustify_c_options', '')
call ale#Set('uncrustify_cpp_options', '')
call ale#Set('uncrustify_cs_options', '')
call ale#Set('uncrustify_objc_options', '')
call ale#Set('uncrustify_d_options', '')
call ale#Set('uncrustify_java_options', '')
call ale#Set('uncrustify_pawn_options', '')
call ale#Set('uncrustify_vala_options', '')
call ale#Set('c_uncrustify_executable', '')
call ale#Set('c_uncrustify_options', '')

function! ale#fixers#uncrustify#Fix(buffer) abort
    let l:uncrustify_filetype_names = {'c': 'C', 'cpp': 'CPP', 'd': 'D', 'cs': 'CS', 'java': 'JAVA', 'pawn': 'PAWN', 'objc': 'OC', 'vala': 'VALA'}
    let l:executable = ale#Var(a:buffer, 'uncrustify_executable')

    if l:executable is? 'uncrustify'
        let l:backward_compat_executable = ale#Var(a:buffer, 'c_uncrustify_executable')

        if !empty(l:backward_compat_executable)
            let l:executable = l:backward_compat_executable
        endif
    endif

    let l:ft = getbufvar(a:buffer, '&filetype')
    let l:global_options = ale#Var(a:buffer, 'uncrustify_global_options')

    if has_key(l:uncrustify_filetype_names, l:ft)
        let l:options = ale#Var(a:buffer, 'uncrustify_' . l:ft . '_options')
        " Pass filetype before global options since uncrustify uses the first occurrence of each flag
        let l:options = l:options . (empty(l:global_options) || empty(l:options) ? '' : ' ') . l:global_options

        " Support deprecated global options variable
        if empty(l:options)
            let l:options = ale#Var(a:buffer, 'c_uncrustify_options')
        endif

        " Put vim filetype before other options since uncrustify uses the first occurence of each flag
        if ale#Var(a:buffer, 'uncrustify_vim_filetype')
            let l:options = '-l ' . l:uncrustify_filetype_names[l:ft] . (empty(l:options) ? '' : ' ' . l:options)
        endif
    else
        " Use just global options if filetype is unknown, supporting deprecated global options variable
        let l:options = empty(l:global_options) ? ale#Var(a:buffer, 'c_uncrustify_options') : l:global_options
    endif

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' --no-backup'
    \       . (empty(l:options) ? '' : ' ' . ale#Escape(l:options))
    \}
endfunction
