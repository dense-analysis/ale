" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with Node executables.

call ale#Set('windows_node_executable_path', 'node.exe')

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

" Create a executable string which executes a Node.js script command with a
" Node.js executable if needed.
"
" The executable string should not be escaped before passing it to this
" function, the executable string will be escaped when returned by this
" function.
"
" Node parameters can be passed as optional function params.
"
" The executable is only prefixed for Windows machines
function! ale#node#Executable(buffer, executable, ...) abort
    "Dont put deprecation warnings into the output
    let l:node_options = join(get(a:, '000', []) + ['--no-deprecation'], ' ')

    if has('win32') && a:executable =~? '\.js$'
        let l:node = ale#Var(a:buffer, 'windows_node_executable_path')
    else
        let l:node = 'node'
    endif

    return ale#Escape(l:node) . ' ' . ale#Escape(l:node_options) . ' ' . ale#Escape(a:executable)
endfunction
