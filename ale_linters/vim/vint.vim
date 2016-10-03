" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

if exists('g:loaded_ale_linters_vim_vint')
    finish
endif

let g:loaded_ale_linters_vim_vint = 1

function! ale_linters#vim#vint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " /home/w0rp/.vim/vimrc:198:30: Prefer single quoted strings (see Google VimScript Style Guide (Strings))
    let pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': 'W',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('vim', {
\   'name': 'vint',
\   'executable': 'vint',
\   'command': g:ale#util#stdin_wrapper . ' .vim vint -w --no-color',
\   'callback': 'ale_linters#haskell#ghc#Handle',
\})
