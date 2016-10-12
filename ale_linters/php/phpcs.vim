" Author: jwilliams108 <https://github.com/jwilliams108>
" Description: phpcs for PHP files

if exists('g:loaded_ale_linters_php_phpcs')
    finish
endif

let g:loaded_ale_linters_php_phpcs = 1

function! ale_linters#php#phpcs#GetCommand(buffer)
    let l:command = 'phpcs -s --report=emacs --stdin-path=%s'

    " This option can be set to change the standard used by phpcs
    if exists('g:ale_php_phpcs_standard')
        let l:command .= ' --standard=' . g:ale_php_phpcs_standard
    endif

    return l:command
endfunction

function! ale_linters#php#phpcs#Handle(buffer, lines)
    " Matches against lines like the following:
    "
    " /path/to/some-filename.php:18:3: error - Line indented incorrectly; expected 4 spaces, found 2 (Generic.WhiteSpace.ScopeIndent.IncorrectExact)
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\) - \(.\+\) \(\(.\+\)\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[4]
        let l:type = l:match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type ==# 'error' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'phpcs',
\   'executable': 'phpcs',
\   'command_callback': 'ale_linters#php#phpcs#GetCommand',
\   'callback': 'ale_linters#php#phpcs#Handle',
\})
