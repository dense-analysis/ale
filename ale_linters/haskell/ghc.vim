" Author: w0rp <devw0rp@gmail.com>
" Description: ghc for Haskell files

if exists('g:loaded_ale_linters_haskell_ghc')
    finish
endif

let g:loaded_ale_linters_haskell_ghc = 1

function! ale_linters#haskell#ghc#Handle(buffer, lines)
    " Look for lines like the following.
    "
    " /dev/stdin:28:26: Not in scope: `>>>>>'
    let pattern = '^[^:]\+:\(\d\+\):\(\d\+\): \(.\+\)$'
    let output = []

    " For some reason the output coming out of the GHC through the wrapper
    " script breaks the lines up in strange ways. So we have to join some
    " lines back together again.
    let corrected_lines = []

    for line in a:lines
        if len(matchlist(line, pattern)) > 0
            call add(corrected_lines, line)
            call add(corrected_lines, '')
        elseif line == ''
            call add(corrected_lines, line)
        else
            if len(corrected_lines) > 0
                let corrected_lines[-1] .= line
            endif
        endif
    endfor

    for line in corrected_lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('haskell', {
\   'name': 'ghc',
\   'output_stream': 'stderr',
\   'executable': 'ghc',
\   'command': g:ale#util#stdin_wrapper . ' .hs ghc -fno-code -v0',
\   'callback': 'ale_linters#haskell#ghc#Handle',
\})
