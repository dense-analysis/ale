" Author: w0rp <devw0rp@gmail.com>
" Description: Lints sh files using bash -n

if exists('g:loaded_ale_linters_sh_shell')
    finish
endif

let g:loaded_ale_linters_sh_shell = 1

" This option can be changed to change the default shell when the shell
" cannot be taken from the hashbang line.
if !exists('g:ale_linters_sh_shell_default_shell')
    let g:ale_linters_sh_shell_default_shell = 'bash'
endif

function! ale_linters#sh#shell#GetExecutable(buffer)
    let shell = g:ale_linters_sh_shell_default_shell

    let banglines = getbufline(a:buffer, 1)

    " Take the shell executable from the hashbang, if we can.
    if len(banglines) == 1
        let bangmatch = matchlist(banglines[0], '^#!\([^ ]\+\)')

        if len(bangmatch) > 0
            let shell = bangmatch[1]
        endif
    endif

    return shell
endfunction

function! ale_linters#sh#shell#GetCommand(buffer)
    return ale_linters#sh#shell#GetExecutable(a:buffer) . ' -n'
endfunction

function! ale_linters#sh#shell#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " bash: line 13: syntax error near unexpected token `d'
    " sh: 11: Syntax error: "(" unexpected
    let pattern = '^[^:]\+: \%(line \|\)\(\d\+\): \(.\+\)'
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

call ALEAddLinter('sh', {
\   'name': 'shell',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#sh#shell#GetExecutable',
\   'command_callback': 'ale_linters#sh#shell#GetCommand',
\   'callback': 'ale_linters#sh#shell#Handle',
\})
