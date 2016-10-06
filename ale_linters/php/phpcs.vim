" Author: jwilliams108 <https://github.com/jwilliams108>
" Description: phpcs for PHP files

if exists('g:loaded_ale_linters_php_phpcs')
    finish
endif

let g:loaded_ale_linters_php_phpcs = 1

function! ale_linters#php#phpcs#GetCommand(buffer)
    let command = 'phpcs -s --report=emacs --stdin-path=%s'

    " This option can be set to change the standard used by phpcs
    if exists('g:ale_linters_php_phpcs_standard')
        let command .= ' --standard=' . g:ale_linters_php_phpcs_standard
    endif

    return command
endfunction

function! ale_linters#php#phpcs#Handle(buffer, lines)
    " Matches against lines like the following:
    "
    " /path/to/some-filename.php:18:3: error - Line indented incorrectly; expected 4 spaces, found 2 (Generic.WhiteSpace.ScopeIndent.IncorrectExact)
    let pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\) - \(.\+\) \(\(.\+\)\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[4]
        let type = l:match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': type ==# 'warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('php', {
\   'name': 'phpcs',
\   'executable': 'phpcs',
\   'command_callback': 'ale_linters#php#phpcs#GetCommand',
\   'callback': 'ale_linters#php#phpcs#Handle',
\})
