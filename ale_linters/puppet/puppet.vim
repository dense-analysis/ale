" Author: Alexander Olofsson <alexander.olofsson@liu.se>

function! ale_linters#puppet#puppet#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " Error: Could not parse for environment production: Syntax error at ':' at /root/puppetcode/modules/nginx/manifests/init.pp:43:12

    let l:pattern = '^Error: .*: \(.\+\) at .\+:\(\d\+\):\(\d\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[1],
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
