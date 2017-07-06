function! ale#fixers#rubocop#GetCommand(buffer) abort
    let l:executable = ale#handlers#rubocop#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? 'bundle$'
    \   ? ' exec rubocop'
    \   : ''
    let l:config = ale#path#FindNearestFile(a:buffer, '.rubocop.yml')

    return ale#Escape(l:executable) . l:exec_args
    \   . (!empty(l:config) ? ' --config ' . ale#Escape(l:config) : '')
    \   . ' --auto-correct %t'

endfunction

function! ale#fixers#rubocop#Fix(buffer) abort
    return {
    \   'command': ale#fixers#rubocop#GetCommand(a:buffer),
    \   'read_temporary_file': 1,
    \}
endfunction
