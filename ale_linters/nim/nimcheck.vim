" Author: Baabelfish
" Description: Typechecking for nim files


function! ale_linters#nim#nimcheck#Handle(buffer, lines) abort
    let l:pattern = '^\(.\+\.nim\)(\(\d\+\), \(\d\+\)) \(.\+\)'
    let l:output = [] 

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:buffer = l:match[1] + 0
        let l:line = l:match[2] + 0
        let l:column = l:match[3] + 0
        let l:text = l:match[4]
        let l:type = 'W'

        let l:textmatch = matchlist(l:match[4], '\(.*\):')

        if len(l:textmatch) > 0
            let l:errortype = l:textmatch[1]
            if l:errortype ==# 'Error'
                let l:type = 'E'
            endif
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction


function! ale_linters#nim#nimcheck#GetCommand(buffer)
    return 'nim check --path:' . fnameescape(fnamemodify(bufname(a:buffer), ':p:h')) . ' --verbosity:0 --colors:off --listFullPaths %t'
endfunction


call ale#linter#Define('nim', {
\    'name': 'nimcheck',
\    'executable': 'nim',
\    'output_stream': 'both',
\    'command_callback': 'ale_linters#nim#nimcheck#GetCommand',
\    'callback': 'ale_linters#nim#nimcheck#Handle'
\})
