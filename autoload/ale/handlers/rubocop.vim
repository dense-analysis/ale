call ale#Set('ruby_rubocop_options', '')
call ale#Set('ruby_rubocop_executable', 'rubocop')

function! ale#handlers#rubocop#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'ruby_rubocop_executable')

    return ale#handlers#ruby#EscapeExecutable(l:executable, 'rubocop')
endfunction
