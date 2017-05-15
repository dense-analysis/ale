" Author: Devon Meunier <devon.meunier@gmail.com>
" Description: checkstyle for Java files

function! ale_linters#java#checkstyle#Handle(buffer, lines) abort
    let l:patterns = [
        \ '\v\[(WARN|ERROR)\] .*:(\d+):(\d+): (.*)',
        \ '\v\[(WARN|ERROR)\] .*:(\d+): (.*)',
        \]
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:patterns)
        let l:args = {
        \   'lnum': l:match[2] + 0,
        \   'type': l:match[1] =~? 'WARN' ? 'W' : 'E'
        \ }

        let l:col = l:match[3] + 0
        if l:col > 0
            let l:args['col'] = l:col
            let l:args['text'] = l:match[4]
        else
            let l:args['text'] = l:match[3]
        endif

        call add(l:output, l:args)
    endfor

    return l:output
endfunction

function! ale_linters#java#checkstyle#GetCommand(buffer) abort
    return 'checkstyle '
    \ . ale#Var(a:buffer, 'java_checkstyle_options')
    \ . ' %t'
endfunction

if !exists('g:ale_java_checkstyle_options')
    let g:ale_java_checkstyle_options = '-c /google_checks.xml'
endif

call ale#linter#Define('java', {
\   'name': 'checkstyle',
\   'executable': 'checkstyle',
\   'command_callback': 'ale_linters#java#checkstyle#GetCommand',
\   'callback': 'ale_linters#java#checkstyle#Handle',
\})
