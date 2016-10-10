" Author: w0rp <devw0rp@gmail.com>
" Description: Lints sh files using bash -n

if exists('g:loaded_ale_linters_sh_shell')
    finish
endif

let g:loaded_ale_linters_sh_shell = 1

" This option can be changed to change the default shell when the shell
" cannot be taken from the hashbang line.
if !exists('g:ale_linters_sh_shell_default_shell')
    let g:ale_linters_sh_shell_default_shell = fnamemodify($SHELL, ':t')

    if g:ale_linters_sh_shell_default_shell ==# ''
        let g:ale_linters_sh_shell_default_shell = 'bash'
    endif
endif

function! ale_linters#sh#shell#GetExecutable(buffer)
    let banglines = getbufline(a:buffer, 1)

    " Take the shell executable from the hashbang, if we can.
    if len(banglines) == 1 && banglines[0] =~# '^#!'
        " Remove options like -e, etc.
        let line = substitute(banglines[0], '--\?[a-zA-Z0-9]\+', '', 'g')

        for possible_shell in ['bash', 'tcsh', 'csh', 'zsh', 'sh']
            if line =~# possible_shell . '\s*$'
                return possible_shell
            endif
        endfor
    endif

    return g:ale_linters_sh_shell_default_shell
endfunction

function! ale_linters#sh#shell#GetCommand(buffer)
    return ale_linters#sh#shell#GetExecutable(a:buffer) . ' -n'
endfunction

function! ale_linters#sh#shell#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " bash: line 13: syntax error near unexpected token `d'
    " sh: 11: Syntax error: "(" unexpected
    let pattern = '^[^:]\+: \%(\w\+ \|\)\(\d\+\): \(.\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[1] + 0
        let column = 1
        let text = l:match[2]
        let type = 'E'

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': column,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#define('sh', {
\   'name': 'shell',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#sh#shell#GetExecutable',
\   'command_callback': 'ale_linters#sh#shell#GetCommand',
\   'callback': 'ale_linters#sh#shell#Handle',
\})
