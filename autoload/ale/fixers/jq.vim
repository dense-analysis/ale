call ale#Set('jq_executable', 'jq')
call ale#Set('jq_use_global', 1)
call ale#Set('jq_options', '')

function! ale#fixers#jq#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'jq', [
    \   'jq',
    \])
endfunction

function! ale#fixers#jq#Fix(buffer) abort
     let l:options = ale#Var(a:buffer, 'jq_options')

     return {
     \  'command': ale#Escape(ale#fixers#jq#GetExecutable(a:buffer))
     \      . ' . ' . l:options,
     \}
     }
endfunction
