call ale#Set('eruby_ruumba_options', '')
call ale#Set('eruby_ruumba_executable', 'ruumba')

function! ale#fixers#ruumba#ProcessRuumbaOutput(buffer, output) abort
    " remove leading json string
    return a:output[1:]
endfunction

function! ale#fixers#ruumba#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'eruby_ruumba_executable')
    let l:config = ale#path#FindNearestFile(a:buffer, '.ruumba.yml')
    let l:options = ale#Var(a:buffer, 'eruby_ruumba_options')

    return ale#eruby#EscapeExecutable(l:executable, 'ruumba')
    \   . (!empty(l:config) ? ' --config ' . ale#Escape(l:config) : '')
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' --auto-correct --format json --force-exclusion '
    \   . '--stdin ' . ale#Escape(expand('#' . a:buffer . ':p'))
endfunction

function! ale#fixers#ruumba#Fix(buffer) abort
    return {
    \   'command': ale#fixers#ruumba#GetCommand(a:buffer),
    \   'process_with': 'ale#fixers#ruumba#ProcessRuumbaOutput',
    \}
endfunction
