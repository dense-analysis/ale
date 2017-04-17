" Author: jwilliams108 <https://github.com/jwilliams108>
" Description: phpcs for PHP files

let g:ale_php_phpcs_standard = get(g:, 'ale_php_phpcs_standard', '')

function! ale_linters#php#phpcs#GetCommand(buffer) abort
    let l:standard = ale#Var(a:buffer, 'php_phpcs_standard')
    let l:standard_option = !empty(l:standard)
    \   ? '--standard=' . l:standard
    \   : ''

    return 'phpcs -s --report=emacs --stdin-path=%s ' . l:standard_option
endfunction

function! ale_linters#php#phpcs#Handle(buffer, lines) abort
    " Matches against lines like the following:
    "
    " /path/to/some-filename.php:18:3: error - Line indented incorrectly; expected 4 spaces, found 2 (Generic.WhiteSpace.ScopeIndent.IncorrectExact)
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\) - \(.\+\) \(\(.\+\)\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:text = l:match[4]
        let l:type = l:match[3]

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type ==# 'error' ? 'E' : 'W',
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
