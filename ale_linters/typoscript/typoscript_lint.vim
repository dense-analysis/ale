" Author: Daniel Siepmann <https://daniel-siepmann.de>
" Description: This file adds support for checking TypoScript with helmich/typo3-typoscript-lint

call ale#Set('typoscript_typoscript_lint_executable', 'typoscript-lint')
call ale#Set('typoscript_typoscript_lint_executable_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#typoscript#typoscript_lint#Handle(buffer, lines) abort
    let l:output = []

    let l:pattern = '\vline\="(\d+)" severity\="(warning|error)" message\="(.+)" source\='

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'type': l:match[2] is? 'warning' ? 'W' : 'E',
        \   'text': l:match[3],
        \   'sub_type': 'style',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('typoscript', {
\   'name': 'typoscript_lint',
\   'executable': {b -> ale#path#FindExecutable(b, 'typoscript_typoscript_lint_executable', [
\       'vendor/bin/typoscript-lint',
\       'typoscript-lint'
\   ])},
\   'output_stream': 'stdout',
\   'command': '%e --format=checkstyle -- %s',
\   'callback': 'ale_linters#typoscript#typoscript_lint#Handle',
\})
