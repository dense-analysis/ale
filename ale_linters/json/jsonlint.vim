" Author: KabbAmine <amine.kabb@gmail.com>

if exists('g:loaded_ale_linters_json_jsonlint')
    finish
endif

let g:loaded_ale_linters_json_jsonlint = 1

function! ale_linters#json#jsonlint#Handle(buffer, lines)
    " Matches patterns like the following:
    " line 2, col 15, found: 'STRING' - expected: 'EOF', '}', ',', ']'.

    let pattern = '^line \(\d\+\), col \(\d*\), \(.\+\)$'
    let output = []

    for line in a:lines
        let match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is needed to indicate that the column is a character
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': match[1] + 0,
        \   'vcol': 0,
        \   'col': match[2] + 0,
        \   'text': match[3],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('json', {
\   'name': 'jsonlint',
\   'executable': 'jsonlint',
\   'output_stream': 'stderr',
\   'command': 'jsonlint --compact -',
\   'callback': 'ale_linters#json#jsonlint#Handle',
\})
