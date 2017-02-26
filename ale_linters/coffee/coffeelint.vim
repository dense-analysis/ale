" Author: Prashanth Chandra https://github.com/prashcr
" Description: coffeelint linter for coffeescript files

function! ale_linters#coffee#coffeelint#GetExecutable(buffer) abort
    return ale#util#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/coffeelint',
    \   'coffeelint'
    \)
endfunction

function! ale_linters#coffee#coffeelint#GetCommand(buffer) abort
    return ale_linters#coffee#coffeelint#GetExecutable(a:buffer)
    \   . ' --stdin --reporter csv'
endfunction

function! ale_linters#coffee#coffeelint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " path,lineNumber,lineNumberEnd,level,message
    " stdin,14,,error,Throwing strings is forbidden
    "
    " Note that we currently ignore lineNumberEnd for multiline errors
    let l:pattern = 'stdin,\(\d\+\),\(\d*\),\(.\+\),\(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:column = 1
        let l:type = l:match[3] ==# 'error' ? 'E' : 'W'
        let l:text = l:match[4]

        " vcol is needed to indicate that the column is a character
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('coffee', {
\   'name': 'coffeelint',
\   'executable_callback': 'ale_linters#coffee#coffeelint#GetExecutable',
\   'command_callback': 'ale_linters#coffee#coffeelint#GetCommand',
\   'callback': 'ale_linters#coffee#coffeelint#Handle',
\})
