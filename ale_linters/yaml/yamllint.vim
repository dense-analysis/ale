" Author: KabbAmine <amine.kabb@gmail.com>

function! ale_linters#yaml#yamllint#Handle(buffer, lines) abort
    " Matches patterns line the following:
    " something.yaml:1:1: [warning] missing document start "---" (document-start)
    " something.yml:2:1: [error] syntax error: expected the node content, but found '<stream end>'
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \[\(error\|warning\)\] \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:col = l:match[2] + 0
        let l:type = l:match[3]
        let l:text = l:match[4]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'vcol': 0,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': l:type ==# 'error' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('yaml', {
\   'name': 'yamllint',
\   'executable': 'yamllint',
\   'command': g:ale#util#stdin_wrapper . ' .yml yamllint -f parsable',
\   'callback': 'ale_linters#yaml#yamllint#Handle',
\})
