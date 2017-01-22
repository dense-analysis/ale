" Author: w0rp <devw0rp@gmail.com>
" Description: ghc for Haskell files

if exists('g:loaded_ale_linters_haskell_ghc')
    finish
endif

let g:loaded_ale_linters_haskell_ghc = 1

function! ale_linters#haskell#ghc#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " /dev/stdin:28:26: Not in scope: `>>>>>'
    let l:pattern = '^[^:]\+:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    " For some reason the output coming out of the GHC through the wrapper
    " script breaks the lines up in strange ways. So we have to join some
    " lines back together again.
    let l:corrected_lines = []

    for l:line in a:lines
        if len(matchlist(l:line, l:pattern)) > 0
            call add(l:corrected_lines, l:line)
            if l:line !~# ': error:$'
                call add(l:corrected_lines, '')
            endif
        elseif l:line ==# ''
            call add(l:corrected_lines, l:line)
        else
            if len(l:corrected_lines) > 0
                let l:line = substitute(l:line, '\v\s+', ' ', '')
                let l:corrected_lines[-1] .= l:line
            endif
        endif
    endfor

    for l:line in l:corrected_lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('haskell', {
\   'name': 'ghc',
\   'output_stream': 'stderr',
\   'executable': 'ghc',
\   'command': g:ale#util#stdin_wrapper . ' .hs ghc -fno-code -v0',
\   'callback': 'ale_linters#haskell#ghc#Handle',
\})

call ale#linter#Define('haskell', {
\   'name': 'stack-ghc',
\   'output_stream': 'stderr',
\   'executable': 'stack',
\   'command': g:ale#util#stdin_wrapper . ' .hs stack ghc -- -fno-code -v0',
\   'callback': 'ale_linters#haskell#ghc#Handle',
\})
