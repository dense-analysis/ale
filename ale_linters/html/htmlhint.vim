" Author: KabbAmine <amine.kabb@gmail.com>
" Description: HTMLHint for checking html files

if exists('g:loaded_ale_linters_html_htmlhint')
    finish
endif

let g:loaded_ale_linters_html_htmlhint = 1

function! ale_linters#html#htmlhint#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    "stdin:7:10: <title></title> must not be empty. [error/title-require]

    let l:pattern = '^stdin:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:col = l:match[2] + 0
        let l:text = l:match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'vcol': 0,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('html', {
\   'name': 'htmlhint',
\   'executable': 'htmlhint',
\   'command': 'htmlhint --format=unix stdin',
\   'callback': 'ale_linters#html#htmlhint#Handle',
\})
