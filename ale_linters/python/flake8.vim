" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

if exists('g:loaded_ale_linters_python_flake8')
    finish
endif

let g:loaded_ale_linters_python_flake8 = 1

function! ale_linters#python#flake8#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " stdin:6:6: E111 indentation is not a multiple of four
    let l:pattern = '^stdin:\(\d\+\):\(\d\+\): \([^ ]\+\) \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:column = l:match[2] + 0
        let l:code = l:match[3]
        let l:text = l:code . ': ' . l:match[4]
        let l:type = l:code[0] ==# 'E' ? 'E' : 'W'

        if (l:code ==# 'W291' || l:code ==# 'W293') && !g:ale_warn_about_trailing_whitespace
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'vcol': 0,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable': 'flake8',
\   'command': 'flake8 -',
\   'callback': 'ale_linters#python#flake8#Handle',
\})
