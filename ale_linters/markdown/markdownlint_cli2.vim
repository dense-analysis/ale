" Author: Horacio Sanson
" Description: Adds support for markdownlint-cli2

call ale#Set('markdown_markdownlint_cli2_executable', 'markdownlint-cli2')
call ale#Set('markdown_markdownlint_cli2_options', '')

function! ale_linters#markdown#markdownlint_cli2#GetExecutable(buffer) abort
    return ale#handlers#markdownlint#GetExecutable(
    \   a:buffer,
    \   'markdownlint_cli2',
    \)
endfunction

function! ale_linters#markdown#markdownlint_cli2#GetCommand(buffer) abort
    return ale#handlers#markdownlint#GetCommand(
    \   a:buffer,
    \   'markdownlint_cli2',
    \)
endfunction

call ale#linter#Define('markdown', {
\   'name': 'markdownlint_cli2',
\   'aliases': ['markdownlint-cli2'],
\   'executable': function('ale_linters#markdown#markdownlint_cli2#GetExecutable'),
\   'lint_file': 1,
\   'output_stream': 'both',
\   'command': function('ale_linters#markdown#markdownlint_cli2#GetCommand'),
\   'callback': 'ale#handlers#markdownlint#Handle',
\})
