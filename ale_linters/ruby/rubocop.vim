" Author: ynonp - https://github.com/ynonp
" Description: rubocop for Ruby files

function! ale_linters#ruby#rubocop#GetCommand(buffer) abort
    let l:executable = ale#handlers#rubocop#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? 'bundle$'
    \   ? ' exec rubocop'
    \   : ''

    return ale#Escape(l:executable) . l:exec_args
    \   . ' --format emacs --force-exclusion '
    \   . ale#Var(a:buffer, 'ruby_rubocop_options')
    \   . ' --stdin ' . bufname(a:buffer)
endfunction

function! ale_linters#ruby#rubocop#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " <path>:83:29: C: Prefer single-quoted strings when you don't
    " need string interpolation or special symbols.
    let l:pattern = '\v:(\d+):(\d+): (.): (.+)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:text = l:match[4]
        let l:type = l:match[3]

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': index(['F', 'E'], l:type) != -1 ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('ruby', {
\   'name': 'rubocop',
\   'executable_callback': 'ale#handlers#rubocop#GetExecutable',
\   'command_callback': 'ale_linters#ruby#rubocop#GetCommand',
\   'callback': 'ale_linters#ruby#rubocop#Handle',
\})
