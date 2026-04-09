" Author: Sam Bottoni
" Description: lilypond linter for LilyPond files

call ale#Set('lilypond_lilypond_executable', 'lilypond')

let g:ale_lilypond_lilypond_options = get(g:, 'ale_lilypond_lilypond_options', '')

function! ale_linters#lilypond#lilypond#GetCommand(buffer) abort
    return '%e --loglevel=WARNING -dbackend=null -dno-print-pages -o /tmp'
    \   . ale#Pad(ale#Var(a:buffer, 'lilypond_lilypond_options'))
    \   . ' %t 2>&1'
endfunction

function! ale_linters#lilypond#lilypond#Handle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        " Match: file:line:col: error|warning|programming error: message
        let l:match = matchlist(l:line,
        \   '\v^.*:(\d+):(\d+): (error|warning|programming error): (.*)$')

        if !empty(l:match)
            call add(l:output, {
            \   'lnum': str2nr(l:match[1]),
            \   'col': str2nr(l:match[2]),
            \   'type': l:match[3] =~? 'error' ? 'E' : 'W',
            \   'text': l:match[4]
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('lilypond', {
\   'name': 'lilypond',
\   'executable': {b -> ale#Var(b, 'lilypond_lilypond_executable')},
\   'command': function('ale_linters#lilypond#lilypond#GetCommand'),
\   'callback': 'ale_linters#lilypond#lilypond#Handle',
\})
