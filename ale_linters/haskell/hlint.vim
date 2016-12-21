" Author: jparoz <jesse.paroz@gmail.com>
" Description: hlint for Haskell files

function! ale_linters#haskell#hlint#Handle(buffer, lines)
    let l:errors = json_decode(join(a:lines, ''))

    let l:output = []

    for l:error in l:errors
        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:error.startLine + 0,
        \   'vcol': 0,
        \   'col': l:error.startColumn + 0,
        \   'text': l:error.severity . ': ' . l:error.hint . '. Found: ' . l:error.from . ' Why not: ' . l:error.to,
        \   'type': l:error.severity ==# 'Error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('haskell', {
\   'name': 'hlint',
\   'executable': 'hlint',
\   'command': 'hlint --color=never --json -',
\   'callback': 'ale_linters#haskell#hlint#Handle',
\})
