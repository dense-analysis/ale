" Author: Patrick Lewis - https://github.com/patricklewis, thenoseman - https://github.com/thenoseman
" Description: haml-lint for Haml files
"
" Options:
" g:ale_haml_hamllint_options can be set and will be passed as options to
" haml-lint
" eg. let g:ale_haml_hamllint_options = '-c ~/use-my.haml-lint.yml'

let g:ale_haml_hamllint_options =
\   get(g:, 'ale_haml_hamllint_options', '')

function! ale_linters#haml#hamllint#GetCommand(buffer) abort
  return 'haml-lint ' . g:ale_haml_hamllint_options . ' %t'
endfunction

function! ale_linters#haml#hamllint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " <path>:51 [W] RuboCop: Use the new Ruby 1.9 hash syntax.
    let l:pattern = '\v^.*:(\d+) \[([EW])\] (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'type': l:match[2],
        \   'text': l:match[3]
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('haml', {
\   'name': 'hamllint',
\   'executable': 'haml-lint',
\   'command_callback': 'ale_linters#haml#hamllint#GetCommand',
\   'callback': 'ale_linters#haml#hamllint#Handle'
\})
