call ale#linter#Define('lilypond', {
\   'name': 'lilypond',
\   'executable': 'lilypond',
\   'command': 'lilypond --loglevel=WARNING -dbackend=null -dno-print-pages -o /tmp %t 2>&1',
\   'callback': 'ale_linters#lilypond#lilypond#Handle',
\})

function! ale_linters#lilypond#lilypond#Handle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        " Match: file:line:col: error|warning|programming error: message
        let l:match = matchlist(
        \   l:line,
        \   '\v^.*:(\d+):(\d+): (error|warning|programming error): (.*)$'
        \)

        if len(l:match) > 0
            call add(l:output, {
            \   'lnum': str2nr(l:match[1]),
            \   'col': str2nr(l:match[2]),
            \   'type': l:match[3] =~? 'error' ? 'E' : 'W',
            \   'text': l:match[4],
            \})
        endif
    endfor

    return l:output
endfunction

