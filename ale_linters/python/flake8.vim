if exists('g:loaded_ale_linters_python_flake8')
    finish
endif

let g:loaded_ale_linters_python_flake8 = 1

function! ale_linters#python#flake8#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " stdin:6:6: E111 indentation is not a multiple of four
    let pattern = '^stdin:\(\d\+\):\(\d\+\): \([^ ]\+\) \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[1] + 0
        let column = l:match[2] + 0
        let code = l:match[3]
        let text = code . ': ' . l:match[4]
        let type = code[0] ==# 'E' ? 'E' : 'W'

        if code ==# 'W291' && !g:ale_warn_about_trailing_whitespace
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': column,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('python', {
\   'executable': 'flake8',
\   'command': 'flake8 -',
\   'callback': 'ale_linters#python#flake8#Handle',
\})
