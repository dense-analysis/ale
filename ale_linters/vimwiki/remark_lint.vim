" Author rhysd https://rhysd.github.io/
" Description: remark-lint for Markdown files

function! ale_linters#markdown#remark_lint#Handle(buffer, lines) abort
    " matches: '  1:4  warning  Incorrect list-item indent: add 1 space  list-item-indent  remark-lint'
    let l:pattern = '^ \+\(\d\+\):\(\d\+\)  \(warning\|error\)  \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'type': l:match[3] is# 'error' ? 'E' : 'W',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('markdown', {
\   'name': 'remark-lint',
\   'executable': 'remark',
\   'command': 'remark --no-stdout --no-color %s',
\   'callback': 'ale_linters#markdown#remark_lint#Handle',
\   'lint_file': 1,
\   'output_stream': 'stderr',
\})
