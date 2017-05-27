" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with Node executables.

" Given a buffer number, a base variable name, and a list of paths to search
" for in ancestor directories, detect the executable path for a Node program.
"
" The use_global and executable options for the relevant program will be used.
function! ale#node#FindExecutable(buffer, base_var_name, path_list) abort
    if ale#Var(a:buffer, a:base_var_name . '_use_global')
        return ale#Var(a:buffer, a:base_var_name . '_executable')
    endif

    for l:path in a:path_list
        let l:executable = ale#path#FindNearestFile(a:buffer, l:path)

        if !empty(l:executable)
            return l:executable
        endif
    endfor

    return ale#Var(a:buffer, a:base_var_name . '_executable')
endfunction
