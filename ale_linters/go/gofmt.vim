" Author: neersighted <bjorn@neersighted.com>
" Description: gofmt for Go files

if exists('g:loaded_ale_linters_go_gofmt')
    finish
endif

let g:loaded_ale_linters_go_gofmt = 1

function! ale_linters#go#gofmt#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " file1.go:5:2: expected declaration, found 'STRING' "log"
    " file2.go:17:2: expected declaration, found 'go'
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
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'gofmt',
\   'output_stream': 'stderr',
\   'executable': 'gofmt',
\   'command': g:ale#util#stdin_wrapper . ' .go gofmt -e',
\   'callback': 'ale_linters#go#gofmt#Handle',
\})

