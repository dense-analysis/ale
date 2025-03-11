" Author: Vivian De Smedt <vds2212@gmail.com>
" Description: Adds support for djlint

call ale#Set('html_djlint_executable', 'djlint')
call ale#Set('html_djlint_options', '')

function! ale_linters#html#djlint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'html_djlint_executable')
endfunction

function! ale_linters#html#djlint#GetCommand(buffer) abort
    let l:executable = ale_linters#html#djlint#GetExecutable(a:buffer)

    let l:options = ale#Var(a:buffer, 'html_djlint_options')

    return ale#Escape(l:executable)
    \ . (!empty(l:options) ? ' ' . l:options : '') . ' %s'
endfunction

function! ale_linters#html#djlint#Handle(buffer, lines) abort
    let l:output = []
    let l:pattern = '\v^([A-Z]\d+) (\d+):(\d+) (.*)$'
    let l:i = 0

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:i += 1
        let l:item = {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'vcol': 1,
        \   'text': l:match[4],
        \   'code': l:match[1],
        \   'type': 'W',
        \}
        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('html', {
\   'name': 'djlint',
\   'executable': function('ale_linters#html#djlint#GetExecutable'),
\   'command': function('ale_linters#html#djlint#GetCommand'),
\   'callback': 'ale_linters#html#djlint#Handle',
\})

" vim:ts=4:sw=4:et:
