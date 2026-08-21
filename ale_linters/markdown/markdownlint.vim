" Author: Ty-Lucas Kelley <tylucaskelley@gmail.com>
" Description: Adds support for markdownlint-cli

call ale#Set('markdown_markdownlint_executable', 'markdownlint')
call ale#Set('markdown_markdownlint_options', '')

function! ale_linters#markdown#markdownlint#GetExecutable(buffer) abort
    return ale#handlers#markdownlint#GetExecutable(
    \   a:buffer,
    \   'markdownlint',
    \)
endfunction

function! ale_linters#markdown#markdownlint#GetCommand(buffer) abort
    return ale#handlers#markdownlint#GetCommand(
    \   a:buffer,
    \   'markdownlint',
    \)
endfunction

call ale#linter#Define('markdown', {
\   'name': 'markdownlint_cli',
\   'aliases': ['markdownlint', 'markdownlint-cli'],
\   'executable': function('ale_linters#markdown#markdownlint#GetExecutable'),
\   'lint_file': 1,
\   'output_stream': 'both',
\   'command': function('ale_linters#markdown#markdownlint#GetCommand'),
\   'callback': 'ale#handlers#markdownlint#Handle',
\})
