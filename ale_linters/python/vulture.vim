" Author: Yauheni Kirylau <actionless.loveless@gmail.com>
" Description: vulture linting for python files

call ale#Set('python_vulture_executable', 'vulture')
call ale#Set('python_vulture_options', '')
call ale#Set('python_vulture_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_vulture_change_directory', 1)

function! ale_linters#python#vulture#GetExecutable(buffer) abort
    return ale#python#FindExecutable(a:buffer, 'python_vulture', ['vulture'])
endfunction

function! ale_linters#python#vulture#GetCommand(buffer) abort
    let l:executable = ale_linters#python#vulture#GetExecutable(a:buffer)

    let l:exec_args = l:executable =~? 'pipenv$'
    \   ? ' run vulture'
    \   : ''

    let l:lint_dest = ale#Var(a:buffer, 'python_vulture_change_directory')
    \   ? fnamemodify(bufname(a:buffer), ':h')
    \   : ' %s'

    return ale#Escape(l:executable) . l:exec_args
    \   . ' '
    \   . ale#Var(a:buffer, 'python_vulture_options')
    \   . l:lint_dest
endfunction

function! ale_linters#python#vulture#Handle(buffer, lines) abort
    for l:line in a:lines[:10]
        if match(l:line, '^Traceback') >= 0
            return [{
            \   'lnum': 1,
            \   'text': 'An exception was thrown. See :ALEDetail',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

    " Matches patterns line the following:
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+): (.*)$'
    let l:bufpath = bufname(a:buffer)
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:path = l:match[1]
        if l:path isnot# l:bufpath && ale#Var(a:buffer, 'python_vulture_change_directory')
            continue
        endif
        let l:item = {
        \   'lnum': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'W',
        \}
        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'vulture',
\   'executable_callback': 'ale_linters#python#vulture#GetExecutable',
\   'command_callback': 'ale_linters#python#vulture#GetCommand',
\   'callback': 'ale_linters#python#vulture#Handle',
\})
