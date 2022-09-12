" Author: Carl Smedstad <carl.smedstad at protonmail dot com>
" Description: bicep for bicep files

let g:ale_bicep_bicep_executable =
\   get(g:, 'ale_bicep_bicep_executable', 'bicep')

let g:ale_bicep_bicep_options =
\   get(g:, 'ale_bicep_bicep_options', 'build --outfile /dev/null')

function! ale_linters#bicep#bicep#Executable(buffer) abort
    return ale#Var(a:buffer, 'bicep_bicep_executable')
endfunction

function! ale_linters#bicep#bicep#Command(buffer) abort
    let l:executable = ale_linters#bicep#bicep#Executable(a:buffer)
    let l:options = ale#Var(a:buffer, 'bicep_bicep_options')

    return ale#Escape(l:executable) . ' ' . l:options . ' %t'
endfunction

function! ale_linters#bicep#bicep#Handle(buffer, lines) abort
    let l:pattern = '\v^.*\((\d+),(\d+)\)\s:\s([a-zA-Z]*)\s([-a-zA-Z0-9]*):\s(.*)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:match[3] is# 'Error'
            let l:type = 'E'
        elseif l:match[3] is# 'Warning'
            let l:type = 'W'
        else
            let l:type = 'I'
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'type': l:type,
        \   'code': l:match[4],
        \   'text': l:match[5],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('bicep', {
\   'name': 'bicep',
\   'executable': function('ale_linters#bicep#bicep#Executable'),
\   'command': function('ale_linters#bicep#bicep#Command'),
\   'callback': 'ale_linters#bicep#bicep#Handle',
\   'output_stream': 'both',
\})
