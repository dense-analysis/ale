call ale#Set('lua_luafmt_executable', 'luafmt')

function! ale#fixers#luafmt#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'lua_luafmt_executable')
endfunction

function! ale#fixers#luafmt#Fix(buffer) abort
    return {
    \   'command': ale#Escape(ale#fixers#luafmt#GetExecutable(a:buffer))
    \   . ' -w replace '
    \   . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
