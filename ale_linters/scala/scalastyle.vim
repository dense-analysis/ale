" Author: Kevin Kays - https://github.com/okkays
" Description: Support for the scalastyle checker.

let g:ale_scalastyle_config_file =
\   get(g:, 'ale_scalastyle_config_file', 'scalastyle-config.xml')

function! ale_linters#scala#scalastyle#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " warning file=/home/blurble/Doop.scala message=Missing or badly formed ScalaDoc: Extra @param foobles line=190

    let l:pattern = '^\(.\+\) .\+ message=\(.\+\) line=\(\d\+\)'
    "let l:pattern = '^.\+:\(\d\+\): \(\w\+\): \(.\+\)'
    let l:output = []
    let l:ln = 0

    for l:line in a:lines
        let l:ln = l:ln + 1
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[2]
        let l:type = l:match[1] ==# 'error' ? 'E' : 'W'
        let l:col = 0

        if l:ln + 1 < len(a:lines)
            let l:col = stridx(a:lines[l:ln + 1], '^')
        endif

        call add(l:output, {
        \   'lnum': l:match[3] + 0,
        \   'col': l:col + 1,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#scala#scalastyle#GetCommand(buffer) abort
    return 'scalastyle -c "' . g:ale_scalastyle_config_file . '" %t'
endfunction

call ale#linter#Define('scala', {
\   'name': 'scalastyle',
\   'executable': 'scalastyle',
\   'output_stream': 'stdout',
\   'command_callback': 'ale_linters#scala#scalastyle#GetCommand',
\   'callback': 'ale_linters#scala#scalastyle#Handle',
\})
