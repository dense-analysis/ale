" Author: KabbAmine <amine.kabb@gmail.com>
" Description: HTMLHint for checking html files

if exists('g:loaded_ale_linters_html_htmlhint')
    finish
endif

let g:loaded_ale_linters_html_htmlhint = 1

function! ale_linters#html#htmlhint#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    "stdin:7:10: <title></title> must not be empty. [error/title-require]

    let pattern = '^stdin:\(\d\+\):\(\d\+\): \(.\+\)$'
    let output = []

    for line in a:lines
        let match = matchlist(line, pattern)

        if len(match) == 0
            continue
        endif

        let line = match[1] + 0
        let col = match[2] + 0
        let text = match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': col,
        \   'text': text,
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('html', {
\   'name': 'htmlhint',
\   'executable': 'htmlhint',
\   'command': 'htmlhint --format=unix stdin',
\   'callback': 'ale_linters#html#htmlhint#Handle',
\})
