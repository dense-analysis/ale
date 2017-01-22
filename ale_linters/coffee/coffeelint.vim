" Author: Prashanth Chandra https://github.com/prashcr
" Description: coffeelint linter for coffeescript files

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
        \   'vcol': 0,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('coffee', {
\   'name': 'coffeelint',
\   'executable': 'coffeelint',
\   'command': 'coffeelint --stdin --reporter csv',
\   'callback': 'ale_linters#coffee#coffeelint#Handle',
\})
