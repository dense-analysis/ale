if exists('g:loaded_ale_linters_javascript_eslint')
    finish
endif

let g:loaded_ale_linters_javascript_eslint = 1

function! ale_linters#javascript#eslint#Handle(lines)
    " Matches patterns line the following:
    "
    " <text>:47:14: Missing trailing comma. [Warning/comma-dangle]
    " <text>:56:41: Missing semicolon. [Error/semi]
    let pattern = '^<text>:\(\d\+\):\(\d\+\): \(.\+\) \[\(.\+\)/\(.\+\)\]'
    let output = []

    for line in a:lines
        let match = matchlist(line, pattern)

        if len(match) == 0
            break
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': bufnr('%'),
        \   'lnum': match[1] + 0,
        \   'vcol': 0,
        \   'col': match[2] + 0,
        \   'text': match[3] . '(' . match[5] . ')',
        \   'type': match[4] ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('javascript', {
\   'executable': 'eslint',
\   'command': 'eslint -f unix --stdin',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})
