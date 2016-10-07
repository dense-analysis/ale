" vim: set et:
" Author: Zoltan Kalmar - https://github.com/kalmiz
" Description: Basic scala support using scalac

if exists('g:loaded_ale_linters_scala_scalac')
    finish
endif

let g:loaded_ale_linters_scala_scalac = 1

function! ale_linters#scala#scalac#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " /var/folders/5q/20rgxx3x1s34g3m14n5bq0x80000gn/T/vv6pSsy/0:26: error: expected class or object definition
    let pattern = '^.\+:\(\d\+\): \(\w\+\): \(.\+\)'
    let output = []
    let ln = 0

    for line in a:lines
        let ln = ln + 1
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[3]
        let type = l:match[2] == 'error' ? 'E' : 'W'
        let col = 0
        if ln + 1 < len(a:lines)
            let col = stridx(a:lines[ln + 1], '^')
            if col == -1
                let col = 0
            endif
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': col + 1,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('scala', {
\   'name': 'scalac',
\   'executable': 'scalac',
\   'output_stream': 'stderr',
\   'command': g:ale#util#stdin_wrapper . ' .scala scalac -Ystop-after:parser',
\   'callback': 'ale_linters#scala#scalac#Handle',
\})
