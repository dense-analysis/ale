" Author: Prashanth Chandra https://github.com/prashcr, Aleh Kashnikau https://github.com/mkusher
" Description: type checker for TypeScript files

function! ale_linters#typescript#typecheck#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " hello.ts[7, 41]: Property 'a' does not exist on type 'A'
    " hello.ts[16, 7]: Type 'A' is not assignable to type 'B'
    "
    let l:pattern = '.\+\.ts\[\(\d\+\), \(\d\+\)\]: \(.\+\)'
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
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('typescript', {
\   'name': 'typecheck',
\   'executable': 'typecheck',
\   'command': 'typecheck %s',
\   'callback': 'ale_linters#typescript#typecheck#Handle',
\})
