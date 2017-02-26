" Author: w0rp <devw0rp@gmail.com>
" Description: Lints sh files using bash -n

" This option can be changed to change the default shell when the shell
" cannot be taken from the hashbang line.
if !exists('g:ale_linters_sh_shell_default_shell')
    let g:ale_linters_sh_shell_default_shell = fnamemodify($SHELL, ':t')

    if g:ale_linters_sh_shell_default_shell ==# ''
        let g:ale_linters_sh_shell_default_shell = 'bash'
    endif
endif

function! ale_linters#sh#shell#GetExecutable(buffer) abort
    let l:banglines = getbufline(a:buffer, 1)

    " Take the shell executable from the hashbang, if we can.
    if len(l:banglines) == 1 && l:banglines[0] =~# '^#!'
        " Remove options like -e, etc.
        let l:line = substitute(l:banglines[0], '--\?[a-zA-Z0-9]\+', '', 'g')

        for l:possible_shell in ['bash', 'tcsh', 'csh', 'zsh', 'sh']
            if l:line =~# l:possible_shell . '\s*$'
                return l:possible_shell
            endif
        endfor
    endif

    return g:ale_linters_sh_shell_default_shell
endfunction

function! ale_linters#sh#shell#GetCommand(buffer) abort
    return ale_linters#sh#shell#GetExecutable(a:buffer) . ' -n'
endfunction

function! ale_linters#sh#shell#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " bash: line 13: syntax error near unexpected token `d'
    " sh: 11: Syntax error: "(" unexpected
    let l:pattern = '^[^:]\+: \%(\w\+ \|\)\(\d\+\): \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:column = 1
        let l:text = l:match[2]
        let l:type = 'E'

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('sh', {
\   'name': 'shell',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#sh#shell#GetExecutable',
\   'command_callback': 'ale_linters#sh#shell#GetCommand',
\   'callback': 'ale_linters#sh#shell#Handle',
\})
