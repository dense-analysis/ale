" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing Python imports with isort.

call ale#Set('python_isort_executable', 'isort')
call ale#Set('python_isort_use_global', 0)

function! ale#fixers#isort#Fix(buffer) abort
    let l:executable = ale#python#FindExecutable(
    \   a:buffer,
    \   'python_isort',
    \   ['isort'],
    \)

    if !ale#python#IsExecutable(l:executable)
        return 0
    endif

    let l:config = ale#path#FindNearestFile(a:buffer, '.isort.cfg')
    let l:config_options = !empty(l:config)
    \   ? ' --settings-path ' . ale#Escape(l:config)
    \   : ''

    return {
    \   'command': ale#Escape(l:executable) . l:config_options . ' -',
    \}
endfunction
