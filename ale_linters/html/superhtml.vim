call ale#Set('html_superhtml_executable', 'superhtml')
call ale#Set('html_superhtml_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#html#superhtml#GetCommand(buffer) abort
    return '%e check --stdin'
endfunction

function! ale_linters#html#superhtml#Handle(buffer, lines) abort
    let l:output = []
    let l:pattern = '^\(.*\):\(\d\+\):\(\d\+\): \(.*\)$'

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if !empty(l:match)
            call add(l:output, {
            \ 'lnum': str2nr(l:match[2]),
            \ 'col': str2nr(l:match[3]),
            \ 'text': l:match[4],
            \ 'type': 'E'
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('html', {
\   'name': 'superhtml',
\   'executable': {b -> ale#Var(b, 'html_superhtml_executable')},
\   'command': function('ale_linters#html#superhtml#GetCommand'),
\   'output_stream': 'stderr',
\   'callback': 'ale_linters#html#superhtml#Handle',
\})
