" Set this option to change Rubocop options.
if !exists('g:ale_ruby_rubocop_options')
    " let g:ale_ruby_rubocop_options = '--lint'
    let g:ale_ruby_rubocop_options = ''
endif

if !exists('g:ale_ruby_rubocop_executable')
    let g:ale_ruby_rubocop_executable = 'rubocop'
endif

function! ale#fixers#rubocop#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'ruby_rubocop_executable')
endfunction

function! ale#fixers#rubocop#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'ruby_rubocop_executable')
    let l:exec_args = l:executable =~? 'bundle$'
    \   ? ' exec rubocop'
    \   : ''

    return ale#Escape(l:executable) . l:exec_args
    \   . ' --format emacs --force-exclusion '
    \   . ale#Var(a:buffer, 'ruby_rubocop_options')
    \   . ' --stdin ' . bufname(a:buffer)
endfunction

function! ale#fixers#rubocop#Fix(buffer) abort
    let l:command = ale#fixers#rubocop#GetCommand(a:buffer)

    return {
    \   'command': ale#Escape(l:command)
    \       . ' --auto-correct %t',
    \   'read_temporary_file': 1,
    \}
endfunction
