" Author: Kevin Kays - https://github.com/okkays
" Description: Support for the scalastyle checker.

let g:ale_scalastyle_config_file =
\   get(g:, 'ale_scalastyle_config_file', 'scalastyle-config.xml')

function! ale_linters#scala#scalastyle#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " warning file=/home/blurble/Doop.scala message=Missing or badly formed ScalaDoc: Extra @param foobles line=190

    let l:patterns = [
        \ '^\(.\+\) .\+ message=\(.\+\) line=\(\d\+\)$',
        \ '^\(.\+\) .\+ message=\(.\+\) line=\(\d\+\) column=\(\d\+\)$',
        \]
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:patterns)
        let l:args = {
        \   'lnum': l:match[3] + 0,
        \   'type': l:match[1] =~? 'error' ? 'E' : 'W',
        \   'text': l:match[2]
        \ }

        let l:col = l:match[4] + 0
        if l:col > 0
            let l:args['col'] = l:col + 1
        endif

        call add(l:output, l:args)
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
