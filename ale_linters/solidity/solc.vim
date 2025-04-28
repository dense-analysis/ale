" Author: Karl Bartel <karl42@gmail.com> - http://karl.berlin/
" Description: Report solc compiler errors in Solidity code

call ale#Set('solidity_solc_executable', 'solc')
call ale#Set('solidity_solc_options', '')

function! ale_linters#solidity#solc#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " Error: Expected ';' but got '('
    "    --> /path/to/file/file.sol:1:10:)
    let l:buffer_name = bufname(a:buffer)
    let l:pattern = '\v(Error|Warning|Note): (.*)$'
    let l:line_and_column_pattern = '\v--\> (.*\.sol):(\d+):(\d+):'
    let l:output = []
    let l:type = "Note"
    let l:text = ""

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            let l:match = matchlist(l:line, l:line_and_column_pattern)
            if len(l:match) > 0 && l:type != "Note" && l:match[1] == l:buffer_name
                call add(l:output, {
                \   'lnum': l:match[2] + 0,
                \   'col': l:match[3] + 0,
                \   'text': l:text,
                \   'type': l:type is? "Error" ? 'E' : 'W',
                \})
            endif
        else
            let l:type = l:match[1]
            let l:text = l:match[2]
        endif
    endfor

    return l:output
endfunction

function! ale_linters#solidity#solc#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'solidity_solc_executable')

    return l:executable . ale#Pad(ale#Var(a:buffer, 'solidity_solc_options')) . ' %s'
endfunction

call ale#linter#Define('solidity', {
\   'name': 'solc',
\   'executable': {b -> ale#Var(b, 'solidity_solc_executable')},
\   'command': function('ale_linters#solidity#solc#GetCommand'),
\   'callback': 'ale_linters#solidity#solc#Handle',
\   'output_stream': 'stderr',
\})
