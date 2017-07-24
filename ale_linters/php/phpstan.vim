" Author: medains <https://github.com/medains>, ardis <https://github.com/ardisdreelath>
" Description: phpstan for PHP files

" Set to change the ruleset
let g:ale_php_phpstan_executable = get(g:, 'ale_php_phpstan_executable', 'phpstan')
let g:ale_php_phpstan_level = get(g:, 'ale_php_phpstan_level', '4')

function! ale_linters#php#phpstan#GetCommand(buffer) abort
    return ale#Var(a:buffer, 'php_phpstan_executable')
    \   . ' analyze -l'
    \   . ale#Var(a:buffer, 'php_phpstan_level')
    \   . ' --errorFormat raw'
    \   . ' %s'
endfunction

function! ale_linters#php#phpstan#Handle(buffer, lines) abort
    " Matches against lines like the following:
    "
    " filename.php:15:message
    " C:\folder\filename.php:15:message
    let l:pattern = '^\([a-zA-Z]:\)\?[^:]\+:\(\d\+\):\(.*\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'phpstan',
\   'executable': 'phpstan',
\   'command_callback': 'ale_linters#php#phpstan#GetCommand',
\   'callback': 'ale_linters#php#phpstan#Handle',
\})
