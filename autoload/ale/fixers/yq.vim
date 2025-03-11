call ale#Set('yaml_yq_executable', 'yq')
call ale#Set('yaml_yq_options', '')
call ale#Set('yaml_yq_filters', '.')

function! ale#fixers#yq#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'yaml_yq_executable')
endfunction

function! ale#fixers#yq#Fix(buffer) abort
    let l:options = ale#Var(a:buffer, 'yaml_yq_options')
    let l:filters = ale#Var(a:buffer, 'yaml_yq_filters')

    if empty(l:filters)
        return 0
    endif

    return {
    \  'command': ale#Escape(ale#fixers#yq#GetExecutable(a:buffer))
    \      . ' ' . l:filters . ' '
    \      . l:options,
    \}
endfunction
