call ale#Set('chef_cookstyle_options', '-a')
call ale#Set('chef_cookstyle_auto_correct_all', 0)
call ale#Set('chef_cookstyle_executable', 'cookstyle')

" Rubocop fixer outputs diagnostics first and then the fixed
" output. These are delimited by a "=======" string that we
" look for to remove everything before it.
function! ale#fixers#cookstyle#PostProcess(buffer, output) abort
    let l:line = 0

    for l:output in a:output
        let l:line = l:line + 1

        if l:output =~# "^=\\+$"
            break
        endif
    endfor

    return a:output[l:line :]
endfunction

function! ale#fixers#cookstyle#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'chef_cookstyle_executable')
    let l:config = ale#path#FindNearestFile(a:buffer, '.rubocop.yml')
    let l:options = ale#Var(a:buffer, 'chef_cookstyle_options')
    let l:auto_correct_all = ale#Var(a:buffer, 'chef_cookstyle_auto_correct_all')

    return ale#ruby#EscapeExecutable(l:executable, 'cookstyle')
    \   . (!empty(l:config) ? ' --config ' . ale#Escape(l:config) : '')
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . (l:auto_correct_all ? ' --auto-correct-all' : ' --auto-correct')
    \   . ' --force-exclusion --stdin %s'
endfunction

function! ale#fixers#cookstyle#Fix(buffer) abort
    return {
    \   'command': ale#fixers#cookstyle#GetCommand(a:buffer),
    \   'process_with': 'ale#fixers#cookstyle#PostProcess'
    \}
endfunction
