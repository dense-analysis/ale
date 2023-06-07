" Author: 0xHyoga <0xHyoga@gmx.com>
" Description: Report starknet-compile errors in cairo 1.0 code

call ale#Set('cairo_starknet_executable', 'starknet-compile')
call ale#Set('cairo_starknet_options', '')

function! ale_linters#cairo#starknet#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " Error: Expected ';' but got '('
    "    --> /path/to/file/file.cairo:1:10:)
    let l:pattern = '\v(error|warning): (.*)$'
    let l:line_and_column_pattern = '\v\.cairo:(\d+):(\d+)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            let l:match = matchlist(l:line, l:line_and_column_pattern)

            if len(l:match) > 0
                let l:index = len(l:output) - 1
                let l:output[l:index]['lnum'] = l:match[1] + 0
                let l:output[l:index]['col'] = l:match[2] + 0
            endif
        else
            let l:isError = l:match[1] is? 'Error'

            call add(l:output, {
            \   'lnum': 0,
            \   'col': 0,
            \   'text': l:match[2],
            \   'type': l:isError ? 'E' : 'W',
            \})
        endif
    endfor

    return l:output
endfunction

function! ale_linters#cairo#starknet#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'cairo_starknet_executable')

    return l:executable . ale#Pad(ale#Var(a:buffer, 'cairo_starknet_options')) . ' %s'
endfunction

call ale#linter#Define('cairo', {
\   'name': 'starknet',
\   'executable': {b -> ale#Var(b, 'cairo_starknet_executable')},
\   'command': function('ale_linters#cairo#starknet#GetCommand'),
\   'callback': 'ale_linters#cairo#starknet#Handle',
\   'output_stream': 'stderr',
\})

