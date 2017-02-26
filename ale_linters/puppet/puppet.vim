" Author: Alexander Olofsson <alexander.olofsson@liu.se>

function! ale_linters#puppet#puppet#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " Error: Could not parse for environment production: Syntax error at ':' at /root/puppetcode/modules/nginx/manifests/init.pp:43:12

    let l:pattern = '^Error: .*: \(.\+\) at .\+:\(\d\+\):\(\d\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is needed to indicate that the column is a character
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[1],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('puppet', {
\   'name': 'puppet',
\   'executable': 'puppet',
\   'output_stream': 'stderr',
\   'command': 'puppet parser validate --color=false %t',
\   'callback': 'ale_linters#puppet#puppet#Handle',
\})
