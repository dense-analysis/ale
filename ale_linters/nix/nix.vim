" Author: Alistair Bill <@alibabzo>
" Description: nix-instantiate linter for nix files

function! ale_linters#nix#nix#Handle(buffer, lines) abort

    let l:pattern = '^\(.\+\): \(.\+\), at .*:\(\d\+\):\(\d\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[3] + 0,
        \   'col': l:match[4] + 0,
        \   'text': l:match[1] . ': ' . l:match[2],
        \   'type': l:match[1] =~# '^error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('nix', {
\   'name': 'nix',
\   'output_stream': 'stderr',
\   'executable': 'nix-instantiate',
\   'command': 'nix-instantiate --parse -',
\   'callback': 'ale_linters#nix#nix#Handle',
\})
