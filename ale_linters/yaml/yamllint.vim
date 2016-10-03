" Author: KabbAmine <amine.kabb@gmail.com>

if exists('g:loaded_ale_linters_yaml_yamllint')
    finish
endif

let g:loaded_ale_linters_yaml_yamllint = 1

function! ale_linters#yaml#yamllint#Handle(buffer, lines)
    " Matches patterns line the following:
    " something.yaml: line 2, col 1, Error - Expected RBRACE at line 2, col 1. (errors)
    "
    let pattern = '^.*:\(\d\+\):\(\d\+\): \[\(error\|warning\)\] \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = match[1] + 0
        let col = match[2] + 0
        let type = match[3]
        let text = printf('[%s]%s', type, match[4])

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': col,
        \   'text': text,
        \   'type': type ==# 'warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('yaml', {
\   'name': 'yamllint',
\   'executable': 'yamllint',
\   'command': g:ale#util#stdin_wrapper . ' .yml yamllint -f parsable',
\   'callback': 'ale_linters#yaml#yamllint#Handle',
\})
