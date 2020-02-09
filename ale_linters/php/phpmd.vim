" Author: medains <https://github.com/medains>, David Sierra <https://github.com/davidsierradz>
" Description: phpmd for PHP files

let g:ale_php_phpmd_executable = get(g:, 'ale_php_phpmd_executable', 'phpmd')

" Set to tell phpmd files with which suffixes to check
let g:ale_php_phpmd_suffixes = get(g:, 'ale_php_phpmd_suffixes', '')

" Set to change the ruleset
let g:ale_php_phpmd_ruleset = get(g:, 'ale_php_phpmd_ruleset', 'cleancode,codesize,controversial,design,naming,unusedcode')

function! ale_linters#php#phpmd#GetCommand(buffer) abort
    let l:suffixes = ale#Var(a:buffer, 'php_phpmd_suffixes')

    if empty(l:suffixes) && &filetype is# 'php'
        let l:suffixes = expand('#' . a:buffer . ':e')
    endif

    let l:suffixes_option = !empty(l:suffixes)
    \   ? ' --suffixes ' . l:suffixes
    \   : ''

    return '%e %s text'
    \   . ale#Pad(ale#Var(a:buffer, 'php_phpmd_ruleset'))
    \   . l:suffixes_option
    \   . ' --ignore-violations-on-exit %t'
endfunction

function! ale_linters#php#phpmd#Handle(buffer, lines) abort
    " Matches against lines like the following:
    "
    " /path/to/some-filename.php:18 message
    let l:pattern = '^.*:\(\d\+\)\s\+\(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'phpmd',
\   'executable': {b -> ale#Var(b, 'php_phpmd_executable')},
\   'command': function('ale_linters#php#phpmd#GetCommand'),
\   'callback': 'ale_linters#php#phpmd#Handle',
\})
