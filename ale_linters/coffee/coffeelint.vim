" Author: Prashanth Chandra https://github.com/prashcr
" Description: coffeelint linter for coffeescript files

if exists('g:loaded_ale_linters_coffee_coffeelint')
    finish
endif

let g:loaded_ale_linters_coffee_coffeelint = 1

function! ale_linters#coffee#coffeelint#Handle(buffer, lines)
    " Matches patterns like the following:
    "
    " path,lineNumber,lineNumberEnd,level,message
    " stdin,14,,error,Throwing strings is forbidden
    " 
    " Note that we currently ignore lineNumberEnd for multiline errors
    let pattern = 'stdin,\(\d\+\),\(\d*\),\(.\+\),\(.\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[1] + 0
        let column = 1
        let type = l:match[3] ==# 'error' ? 'E' : 'W'
        let text = l:match[3] . ': ' . l:match[4]

        " vcol is needed to indicate that the column is a character
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': column,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('coffee', {
\   'name': 'coffeelint',
\   'executable': 'coffeelint',
\   'command': 'coffeelint --stdin --reporter csv',
\   'callback': 'ale_linters#coffee#coffeelint#Handle',
\})
