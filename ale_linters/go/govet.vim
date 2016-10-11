" Author: neersighted <bjorn@neersighted.com>
" Description: go vet for Go files

if exists('g:loaded_ale_linters_go_govet')
    finish
endif

let g:loaded_ale_linters_go_govet = 1

function! ale_linters#go#govet#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " file.go:27: missing argument for Printf("%s"): format reads arg 2, have only 1 args
    let l:pattern = '^.*:\(\d\+\): \(.\+\)$'
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
        \   'col': 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'go vet',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command': g:ale#util#stdin_wrapper . ' .go go vet',
\   'callback': 'ale_linters#go#govet#Handle',
\})

