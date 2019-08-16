" Author: Baeo Maltinsky <maltinsky.net>
" Description: Integration of sql-formatter-cli with ALE.

call ale#Set('sql_sql_formatter_cli_executable', 'sql-formatter-cli')
call ale#Set('sql_sql_formatter_cli_options', '')

function! ale#fixers#sql_formatter_cli#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'sql_sql_formatter_cli_executable')
endfunction

function! ale#fixers#sql_formatter_cli#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'sql_sql_formatter_cli_options')

    return {
    \ 'command': ale#Escape(ale#fixers#sql_formatter_cli#GetExecutable(a:buffer))
    \     . (empty(l:options) ? '' : ' ' . l:options),
    \}
endfunction

