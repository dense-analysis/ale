" Author: Zefei Xuan <https://github.com/zefei>
" Description: Hack type checking (http://hacklang.org/)

function! ale_linters#php#hack#Handle(buffer, lines) abort
    let l:pattern = '^\(.*\):\(\d\+\):\(\d\+\),\(\d\+\): \(.\+])\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        if a:buffer != bufnr(l:match[1])
          continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[5],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'hack',
\   'executable': 'hh_client',
\   'command': 'hh_client --retries 0 --retry-if-init false',
\   'callback': 'ale_linters#php#hack#Handle',
\})
