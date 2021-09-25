" Author: meain <abinsimon10@gmail.com>
" Description: Fixing HTML files with tidy.

call ale#Set('html_tidy_executable', 'tidy')
call ale#Set('html_tidy_fixer_options', '')
call ale#Set('html_tidy_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#tidy#Fix(buffer) abort
    let l:executable = ale#path#FindExecutable(
    \   a:buffer,
    \   'html_tidy',
    \   ['tidy'],
    \)

    if !executable(l:executable)
        return 0
    endif

    let l:command = [ale#Escape(l:executable)]
    call extend(l:command, ['-q', '--tidy-mark no', '--show-errors 0', '--show-warnings 0'])

    let l:options = ale#Var(a:buffer, 'html_tidy_fixer_options')

    if !empty(l:options)
        call add(l:command, l:options)
    endif

    let l:config = ale#path#FindNearestFile(a:buffer, '.tidyrc')

    if !empty(l:config)
        call add(l:command, '-config ' . ale#Escape(l:config))
    endif

    call add(l:command, '-')

    return {
    \   'command':  join(l:command, ' '),
    \}
endfunction
