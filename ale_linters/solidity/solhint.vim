" Authors: Franco Victorio - https://github.com/fvictorio, Henrique Barcelos
" https://github.com/hbarcelos
" Description: Report errors in Solidity code with solhint

function! ale_linters#solidity#solhint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " /path/to/file/file.sol: line 1, col 10, Error - 'addOne' is defined but never used. (no-unused-vars)
    let l:output = []

    let l:lint_pattern = '\v^[^:]+: line (\d+), col (\d+), (Error|Warning) - (.*) \((.*)\)$'

    for l:match in ale#util#GetMatches(a:lines, l:lint_pattern)
        let l:isError = l:match[3] is? 'error'
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'code': l:match[5],
        \   'type': l:isError ? 'E' : 'W',
        \})
    endfor

    let l:syntax_pattern = '\v^[^:]+: line (\d+), col (\d+), (Error|Warning) - (Parse error): (.*)$'

    for l:match in ale#util#GetMatches(a:lines, l:syntax_pattern)
        let l:isError = l:match[3] is? 'error'
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[5],
        \   'code': l:match[4],
        \   'type': l:isError ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('solidity', {
\   'name': 'solhint',
\   'executable': function('ale#handlers#solhint#GetExecutable'),
\   'command': function('ale#handlers#solhint#GetCommand'),
\   'callback': 'ale_linters#solidity#solhint#Handle',
\})
