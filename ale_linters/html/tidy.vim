" Author: KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking HTML code with tidy.

if exists('g:loaded_ale_linters_html_tidy')
    finish
endif

let g:loaded_ale_linters_html_tidy = 1

function! ale_linters#html#tidy#Handle(buffer, lines)
    " Matches patterns lines like the following:
    " line 7 column 5 - Warning: missing </title> before </head>

    let pattern = '^line \(\d\+\) column \(\d\+\) - \(Warning\|Error\): \(.\+\)$'
    let output = []

    for line in a:lines
        let match = matchlist(line, pattern)

        if len(match) == 0
            continue
        endif

        let line = match[1] + 0
        let col = match[2] + 0
        let type = match[3] ==# 'Error' ? 'E' : 'W'
        let text = printf('[%s]%s', match[3], match[4])

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': col,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

" User options
let g:ale_html_tidy_executable = get(g:, 'ale_html_tidy_executable', 'tidy')
let g:ale_html_tidy_args = get(g:, 'ale_html_tidy_args', '-q -e -language en')

call ALEAddLinter('html', {
\   'name': g:ale_html_tidy_executable,
\   'executable': g:ale_html_tidy_executable,
\   'command': printf('%s %s -', g:ale_html_tidy_executable, g:ale_html_tidy_args),
\   'output_stream': 'stderr',
\   'callback': 'ale_linters#html#tidy#Handle',
\})
