call ale#Set('typescript_dprint_executable', 'dprint')
call ale#Set('typescript_dprint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('typescript_dprint_options', '')

function! ale#fixers#dprint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'typescript_dprint', [
    \   'node_modules/dprint/dist/cli-bin.js',
    \   'node_modules/.bin/dprint',
    \   'dprint',
    \])
endfunction

function! ale#fixers#dprint#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'typescript_dprint_options')

    return {
    \   'command': ale#Escape(ale#fixers#dprint#GetExecutable(a:buffer))
    \       . ' ' . ale#Escape(l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
