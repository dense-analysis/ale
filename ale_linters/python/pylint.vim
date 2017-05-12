" Author: keith <k@keith.so>
" Description: pylint for python files

let g:ale_python_pylint_executable =
\   get(g:, 'ale_python_pylint_executable', 'pylint')

let g:ale_python_pylint_options =
\   get(g:, 'ale_python_pylint_options', '')

let g:ale_python_pylint_use_global = get(g:, 'ale_python_pylint_use_global', 0)

function! ale_linters#python#pylint#GetExecutable(buffer) abort
    if !ale#Var(a:buffer, 'python_pylint_use_global')
        let l:virtualenv = ale#python#FindVirtualenv(a:buffer)

        if !empty(l:virtualenv)
            let l:ve_pylint = l:virtualenv . '/bin/pylint'

            if executable(l:ve_pylint)
                return l:ve_pylint
            endif
        endif
    endif

    return ale#Var(a:buffer, 'python_pylint_executable')
endfunction

function! ale_linters#python#pylint#GetCommand(buffer) abort
    return ale#Escape(ale_linters#python#pylint#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'python_pylint_options')
    \   . ' --output-format text --msg-template="{path}:{line}:{column}: {msg_id} ({symbol}) {msg}" --reports n'
    \   . ' %s'
endfunction

call ale#linter#Define('python', {
\   'name': 'pylint',
\   'executable_callback': 'ale_linters#python#pylint#GetExecutable',
\   'command_callback': 'ale_linters#python#pylint#GetCommand',
\   'callback': 'ale#handlers#python#HandlePEP8Format',
\   'lint_file': 1,
\})
