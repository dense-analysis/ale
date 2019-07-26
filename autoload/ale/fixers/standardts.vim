" Description: Fixing files with Standard for typescript.

call ale#Set('typescript_standard_executable', 'standard')
call ale#Set('typescript_standard_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('typescript_standard_options', '')

function! ale#fixers#standardts#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'typescript_standard', [
    \   'node_modules/standard/bin/cmd.js',
    \   'node_modules/.bin/standard',
    \])
endfunction

function! ale#fixers#standardts#Fix(buffer) abort
    let l:executable = ale#fixers#standardts#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'typescript_standard_options')

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
