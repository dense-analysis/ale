" Author: medains <https://github.com/medains>
" Description: phpmd for PHP files

" Set to change the ruleset
let g:ale_php_phpmd_ruleset = get(g:, 'ale_php_phpmd_ruleset', 'cleancode,codesize,controversial,design,naming,unusedcode')

function! ale_linters#php#phpmd#Handle(buffer, lines) abort
    " Matches against lines like the following:
    "
    " /path/to/some-filename.php:18 message
    let l:pattern = '^.*:\(\d\+\)\t\(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'phpmd',
\   'executable': 'phpmd',
\   'command': 'phpmd %s text ' . g:ale_php_phpmd_ruleset . ' --ignore-violations-on-exit %t',
\   'callback': 'ale_linters#php#phpmd#Handle',
\})
