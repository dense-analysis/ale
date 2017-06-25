" Author: w0rp <devw0rp@gmail.com>
" Description: Error handling for the format GHC outputs.

function! ale#handlers#haskell#HandleGHCFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    "Appoint/Lib.hs:8:1: warning:
    "Appoint/Lib.hs:8:1:
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):(\d+):(.*)?$'
    let l:output = []

    let l:corrected_lines = []

    for l:line in a:lines
        if len(matchlist(l:line, l:pattern)) > 0
            call add(l:corrected_lines, l:line)
        elseif l:line ==# ''
            call add(l:corrected_lines, l:line)
        else
            if len(l:corrected_lines) > 0
                let l:line = substitute(l:line, '\v^\s+', ' ', '')
                let l:corrected_lines[-1] .= l:line
            endif
        endif
    endfor

    for l:line in l:corrected_lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        if !ale#path#IsBufferPath(a:buffer, l:match[1])
            continue
        endif

        let l:errors = matchlist(l:match[4], '\(warning:\|error:\)\(.*\)')

        if len(l:errors) > 0
          let l:type = l:errors[1]
          let l:text = l:errors[2]
        else
          let l:type = ''
          let l:text = l:match[4]
        endif

        let l:type = l:type ==# '' ? 'E' : toupper(l:type[0])

        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction
