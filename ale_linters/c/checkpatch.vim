" Author: Matt Ihlenfield, mtihlenfield@protonmail.com
" Description: checkpatch linter for c files

let s:default_options = '--strict --no-tree'

" Set the  location of the checkpatch executable. By default it assumes it
" is in $(pwd)/scripts/checkpatch.pl
call ale#Set('c_checkpatch_executable', '')

call ale#Set('c_checkpatch_options', s:default_options)

function! ale_linters#c#checkpatch#GetExecutable(buffer) abort
    let l:checkpatch_executable = ale#Var(a:buffer, 'c_checkpatch_executable')

    if l:checkpatch_executable  is# ''
        let l:checkpatch_executable = fnamemodify('./scripts/checkpatch.pl', ':p')
    endif

    return l:checkpatch_executable
endfunction

function! ale_linters#c#checkpatch#GetCommand(buffer) abort
    let l:executable = ale_linters#c#checkpatch#GetExecutable(a:buffer)
    let l:required_options = ' --terse --no-summary'

    return ale#Escape(l:executable)
                \ . l:required_options . ' '
                \ . ale#Var(a:buffer, 'c_checkpatch_options')
                \ . ' -f %s'
endfunction

function! ale_linters#c#checkpatch#Handle(buffer, lines) abort
    let l:linter_messages = []
    let l:regex = '^.*:\(\d\+\): \(WARNING\|ERROR\|CHECK\):\(.*\)'

    for l:match in ale#util#GetMatches(a:lines, l:regex)
        let l:message = {
        \     'text': l:match[2] . ': ' . l:match[3],
        \     'lnum': l:match[1],
        \     'type': l:match[2] is# 'ERROR' ? 'E' : 'W'
        \ }

        let l:linter_messages = add(l:linter_messages, l:message)
    endfor

    return l:linter_messages
endfunction


" Have to use lint_file because checkpatch treats the file as a patch
" when passed in via stdin
call ale#linter#Define('c', {
\    'name': 'checkpatch',
\    'executable_callback': 'ale_linters#c#checkpatch#GetExecutable',
\    'command_callback': 'ale_linters#c#checkpatch#GetCommand',
\    'callback': 'ale_linters#c#checkpatch#Handle',
\    'lint_file': 1
\ })

