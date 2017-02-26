" Author: KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking HTML code with tidy.

" CLI options
let g:ale_html_tidy_executable = get(g:, 'ale_html_tidy_executable', 'tidy')
let g:ale_html_tidy_args = get(g:, 'ale_html_tidy_args', '-q -e -language en')

function! ale_linters#html#tidy#GetCommand(buffer) abort
    " Specify file encoding in options
    " (Idea taken from https://github.com/scrooloose/syntastic/blob/master/syntax_checkers/html/tidy.vim)
    let l:file_encoding = get({
    \   'ascii':        '-ascii',
    \   'big5':         '-big5',
    \   'cp1252':       '-win1252',
    \   'cp850':        '-ibm858',
    \   'cp932':        '-shiftjis',
    \   'iso-2022-jp':  '-iso-2022',
    \   'latin1':       '-latin1',
    \   'macroman':     '-mac',
    \   'sjis':         '-shiftjis',
    \   'utf-16le':     '-utf16le',
    \   'utf-16':       '-utf16',
    \   'utf-8':        '-utf8',
    \ }, &fileencoding, '-utf8')

    return printf('%s %s %s -',
    \   g:ale_html_tidy_executable,
    \   g:ale_html_tidy_args,
    \   l:file_encoding
    \ )
endfunction

function! ale_linters#html#tidy#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " line 7 column 5 - Warning: missing </title> before </head>

    let l:pattern = '^line \(\d\+\) column \(\d\+\) - \(Warning\|Error\): \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:col = l:match[2] + 0
        let l:type = l:match[3] ==# 'Error' ? 'E' : 'W'
        let l:text = l:match[4]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('html', {
\   'name': 'tidy',
\   'executable': g:ale_html_tidy_executable,
\   'output_stream': 'stderr',
\   'command_callback': 'ale_linters#html#tidy#GetCommand',
\   'callback': 'ale_linters#html#tidy#Handle',
\ })
