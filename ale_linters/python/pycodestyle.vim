" Author: Michael Thiesen <micthiesen@gmail.com>
" Description: pycodestyle linting for python files

call ale#Set('python_pycodestyle_executable', 'pycodestyle')
call ale#Set('python_pycodestyle_options', '')
call ale#Set('python_pycodestyle_use_global', 0)

function! ale_linters#python#pycodestyle#GetExecutable(buffer) abort
    return ale#python#FindExecutable(a:buffer, 'python_pycodestyle', ['pycodestyle'])
endfunction

function! ale_linters#python#pycodestyle#GetCommand(buffer) abort
    return ale#Escape(ale_linters#python#pycodestyle#GetExecutable(a:buffer))
    \   . ' '
    \   . ale#Var(a:buffer, 'python_pycodestyle_options')
    \   . ' -'
endfunction

function! ale_linters#python#pycodestyle#Handle(buffer, lines) abort
    let l:pattern = '\v^(\S*):(\d*):(\d*): ((([EW])\d+) .*)$'
    let l:output = []

    " lines are formatted as follows:
    " file.py:21:26: W291 trailing whitespace
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': l:match[6],
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'pycodestyle',
\   'executable_callback': 'ale_linters#python#pycodestyle#GetExecutable',
\   'command_callback': 'ale_linters#python#pycodestyle#GetCommand',
\   'callback': 'ale_linters#python#pycodestyle#Handle',
\})
