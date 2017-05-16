" Author: q12321q <q12321q@gmail.com>
" Description: This file adds support for checking XML code with xmllint.

" CLI options
let g:ale_xml_xmllint_executable = get(g:, 'ale_xml_xmllint_executable', 'xmllint')
let g:ale_xml_xmllint_options = get(g:, 'ale_xml_xmllint_options', '--noout')

function! ale_linters#xml#xmllint#GetCommand(buffer) abort
    return printf('%s %s -',
    \   g:ale_xml_xmllint_executable,
    \   g:ale_xml_xmllint_options
    \ )
endfunction

function! ale_linters#xml#xmllint#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " file/path:123: error level : error message
    let l:pattern_message = '\v^([^:]+):(\d+):\s+([^:]+)\s+:\s+(.*)$'

    " parse column token line like that:
    " file/path:123: parser error : Opening and ending tag mismatch: foo line 1 and bar
    " </bar>
    "       ^
    let l:pattern_column_token = '\v^\s+\^$'

    let l:output = []

    for l:line in a:lines

        " Parse error/warning lines
        let l:match_message = matchlist(l:line, l:pattern_message)
        if len(l:match_message)
          let l:line = l:match_message[2] + 0
          let l:type = 'E'
          if match(l:match_message[3], 'warning') != -1
            let l:type = 'W'
          endif
          let l:text = l:type . ' ' . l:match_message[3] . ' : ' . l:match_message[4]

          call add(l:output, {
          \   'bufnr': a:buffer,
          \   'lnum': l:line,
          \   'text': l:text,
          \   'type': l:type,
          \})

          continue
        endif

        " Parse column position
        let l:match_column_token = matchlist(l:line, l:pattern_column_token)
        if len(l:output) && len(l:match_column_token)
          let l:previous = l:output[len(l:output)-1]
          let l:previous['col'] = len(l:match_column_token[0])

          continue
        endif

    endfor

    return l:output
endfunction

call ale#linter#Define('xml', {
\   'name': 'xmllint',
\   'executable': g:ale_xml_xmllint_executable,
\   'output_stream': 'stderr',
\   'command_callback': 'ale_linters#xml#xmllint#GetCommand',
\   'callback': 'ale_linters#xml#xmllint#Handle',
\ })
