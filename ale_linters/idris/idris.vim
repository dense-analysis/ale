" Author: Scott Bonds <scott@ggr.com>
" Description: default Idris compiler

function! ale_linters#idris#idris#Handle(buffer, lines) abort
    " This was copied almost verbatim from ale#handlers#haskell#HandleGHCFormat

    " Look for lines like the following:
    " blah.idr:2:6:When checking right hand side of main with expected type"
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):(\d+):(.*)?$'
    let l:output = []

    let l:corrected_lines = []

    for l:line in a:lines
        if len(matchlist(l:line, l:pattern)) > 0
            call add(l:corrected_lines, l:line)
        elseif len(l:corrected_lines) > 0
            if l:line is# ''
                let l:corrected_lines[-1] .= ' ' " turn a blank line into a space
            else
                let l:corrected_lines[-1] .= l:line
            endif
            let l:corrected_lines[-1] = substitute(l:corrected_lines[-1], '\s\+', ' ', 'g')
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

        let l:errors = matchlist(l:match[4], '\v([wW]arning|[eE]rror): ?(.*)')

        if len(l:errors) > 0
          let l:ghc_type = l:errors[1]
          let l:text = l:errors[2]
        else
          let l:ghc_type = ''
          let l:text = l:match[4][:0] is# ' ' ? l:match[4][1:] : l:match[4]
        endif

        if l:ghc_type is? 'Warning'
            let l:type = 'W'
        else
            let l:type = 'E'
        endif

        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('idris', {
\   'name': 'idris',
\   'executable': 'idris',
\   'command': 'idris --total --warnpartial --warnreach --warnipkg --check %t',
\   'callback': 'ale_linters#idris#idris#Handle',
\})

