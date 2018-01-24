call ale#Set('json_jq_executable', 'jq')
call ale#Set('json_jq_use_global', 0)
call ale#Set('json_jq_options', '')

function! ale#fixers#jq#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'jq', [
    \   'jq',
    \])
endfunction

function! ale#fixers#jq#Fix(buffer) abort
     let l:options = ale#Var(a:buffer, 'json_jq_options')

     return {
     \  'command': ale#Escape(ale#fixers#jq#GetExecutable(a:buffer))
     \      . ' . ' . l:options,
     \}
endfunction
