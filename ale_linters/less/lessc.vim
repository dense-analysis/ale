" Author: zanona <https://github.com/zanona>, w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking Less code with lessc.

call ale#Set('less_lessc_options', '')

function! ale_linters#less#lessc#GetCommand(buffer) abort
    return 'lessc'
          \ . ' --no-color --lint '
          \ . ale#Var(a:buffer, 'less_lessc_options')
          \ . ' %t'
endfunction

function! ale_linters#less#lessc#Handle(buffer, lines) abort
    " Matches patterns like the following:
    let l:pattern = '^\(\w\+\): \(.\{-}\) in \(.\{-}\) on line \(\d\+\), column \(\d\+\):$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[4] + 0,
        \   'col': l:match[5] + 0,
        \   'text': l:match[2],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('less', {
\   'name': 'lessc',
\   'executable': 'lessc',
\   'output_stream': 'stderr',
\   'command_callback': 'ale_linters#less#lessc#GetCommand',
\   'callback': 'ale_linters#less#lessc#Handle',
\})
