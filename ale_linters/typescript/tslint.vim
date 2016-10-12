" Author: Prashanth Chandra https://github.com/prashcr
" Description: tslint for TypeScript files

if exists('g:loaded_ale_linters_typescript_tslint')
    finish
endif

let g:loaded_ale_linters_typescript_tslint = 1

function! ale_linters#typescript#tslint#Handle(buffer, lines)
    " Matches patterns like the following:
    "
    " hello.ts[7, 41]: trailing whitespace
    " hello.ts[5, 1]: Forbidden 'var' keyword, use 'let' or 'const' instead
    "
    let l:pattern = '.\+.ts\[\(\d\+\), \(\d\+\)\]: \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:column = l:match[2] + 0
        let l:type = 'E'
        let l:text = l:match[3]

        " vcol is Needed to indicate that the column is a character.
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

call ale#linter#Define('typescript', {
\   'name': 'tslint',
\   'executable': 'tslint',
\   'command': g:ale#util#stdin_wrapper . ' .ts tslint',
\   'callback': 'ale_linters#typescript#tslint#Handle',
\})
