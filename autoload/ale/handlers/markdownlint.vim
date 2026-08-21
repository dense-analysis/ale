" Author: Ty-Lucas Kelley <tylucaskelley@gmail.com>
" Description: Adds support for markdownlint

function! ale#handlers#markdownlint#GetExecutable(buffer, name) abort
    return ale#Var(a:buffer, 'markdown_' . a:name . '_executable')
endfunction

function! ale#handlers#markdownlint#GetCommand(buffer, name) abort
    let l:executable = ale#handlers#markdownlint#GetExecutable(
    \   a:buffer,
    \   a:name,
    \)
    let l:options = ale#Var(
    \   a:buffer,
    \   'markdown_' . a:name . '_options',
    \)

    return ale#Escape(l:executable) . ale#Pad(l:options) . ' %s'
endfunction

function! ale#handlers#markdownlint#Handle(buffer, lines) abort
    let l:pattern=': \?\(\d\+\)\(:\(\d\+\)\?\)\? \(error\|warning\)\? \?\(MD\d\{3}/[A-Za-z0-9-/]\+\) \(.*\)$'
    let l:output=[]

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:type = 'W'

        if l:match[4] is# 'error'
            let l:type = 'E'
        endif

        let l:result = ({
        \ 'lnum': l:match[1] + 0,
        \ 'code': l:match[5],
        \ 'text': l:match[6],
        \ 'type': l:type,
        \})

        if len(l:match[3]) > 0
            let l:result.col = (l:match[3] + 0)
        endif

        call add(l:output, l:result)
    endfor

    return l:output
endfunction
