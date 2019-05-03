" Author: aclemons - https://github.com/aclemons
" based on the ale rubocop linter
" Description: Ruumba, RuboCop linting for ERB templates.

call ale#Set('eruby_ruumba_executable', 'ruumba')
call ale#Set('eruby_ruumba_options', '')

function! ale_linters#eruby#ruumba#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'eruby_ruumba_executable')

    return ale#eruby#EscapeExecutable(l:executable, 'ruumba')
    \   . ' --format json --force-exclusion '
    \   . ale#Var(a:buffer, 'eruby_ruumba_options')
    \   . ' --stdin ' . ale#Escape(expand('#' . a:buffer . ':p'))
endfunction

function! ale_linters#eruby#ruumba#GetType(severity) abort
    if a:severity is? 'convention'
    \|| a:severity is? 'warning'
    \|| a:severity is? 'refactor'
        return 'W'
    endif

    return 'E'
endfunction

call ale#linter#Define('eruby', {
\   'name': 'ruumba',
\   'executable': {b -> ale#Var(b, 'eruby_ruumba_executable')},
\   'command': function('ale_linters#eruby#ruumba#GetCommand'),
\   'callback': 'ale#eruby#HandleRuumbaOutput',
\})
