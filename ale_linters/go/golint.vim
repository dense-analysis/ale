" Author: neersighted <bjorn@neersighted.com>
" Description: golint for Go files

if exists('g:loaded_ale_linters_go_golint')
    finish
endif

let g:loaded_ale_linters_go_golint = 1

function! ale_linters#go#golint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " file1.go:53:10: if block ends with a return statement, so drop this else and outdent its block (move short variable declaration to its own line if necessary)
    " file2.go:67:14: should omit type [][]byte from declaration of var matches; it will be inferred from the right-hand side
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'golint',
\   'executable': 'golint',
\   'command': g:ale#util#stdin_wrapper . ' .go golint',
\   'callback': 'ale_linters#go#golint#Handle',
\})
