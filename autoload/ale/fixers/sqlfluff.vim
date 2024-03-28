" Author: Carl Smedstad <carl.smedstad at protonmail dot com>
" Description: Fixing SQL files with sqlfluff

call ale#Set('sql_sqlfluff_executable', 'sqlfluff')

function! ale#fixers#sqlfluff#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'sql_sqlfluff_executable')
    let l:options = ale#Var(a:buffer, 'sql_sqlfluff_options')

    let l:cmd =
    \    ale#Escape(l:executable)
    \    . ' fix --force '
    \    . l:options

    let l:config_file = ale#path#FindNearestFile(a:buffer, ale#Var(a:buffer, 'sql_sqlfluff_config_file'))

    if !empty(l:config_file)
        let l:cmd .= ' --config ' . ale#Escape(l:config_file)
    else
        let l:cmd .= ' --dialect ansi'
    endif

    return {
    \   'command': l:cmd . ' %t > /dev/null',
    \   'read_temporary_file': 1,
    \}
endfunction
