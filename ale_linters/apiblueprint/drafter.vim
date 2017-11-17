function! ale_linters#apiblueprint#drafter#HandleErrors(buffer, lines) abort
    " Matches patterns line the following:
    "
    " warning: (3)  unable to parse response signature, expected 'response [<HTTP status code>] [(<media type>)]'; line 4, column 3k - line 4, column 22
    " warning: (10)  message-body asset is expected to be a pre-formatted code block, separate it by a newline and indent every of its line by 12 spaces or 3 tabs; line 30, column 5 - line 30, column 9; line 31, column 9 - line 31, column 14; line 32, column 9 - line 32, column 14
    let l:pattern = '\(^.*\): (\d\+)  \(.\{-\}\); line \(\d\+\), column \(\d\+\) - line \d\+, column \d\+\(.*; line \(\d\+\), column \(\d\+\) - line \d\+, column \(\d\+\)\)\{-\}$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines[2:], l:pattern)
        let l:type = l:match[1]
        call add(l:output, {
        \   'text': l:match[2],
        \   'lnum': l:match[3] + 0,
        \   'col': l:match[4] + 0,
        \   'end_lnum': l:match[6] + 0,
        \   'end_col': l:match[8] + 0,
        \   'type': l:type is# 'warning' ? 'W' : 'E',
        \})
    endfor

    return l:output
endfunction


call ale#linter#Define('apiblueprint', {
\   'name': 'drafter',
\   'output_stream': 'stderr',
\   'executable': 'drafter',
\   'command': 'drafter --use-line-num --validate %t',
\   'callback': 'ale_linters#apiblueprint#drafter#HandleErrors',
\})
