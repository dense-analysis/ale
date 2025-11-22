" Description: named-checkzone for bindzone

call ale#Set('bindzone_checkzone_executable', 'named-checkzone')
call ale#Set('bindzone_checkzone_options', '-c IN')

function! ale_linters#bindzone#checkzone#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'bindzone_checkzone_options'))
    \   . ' example.com %t'
endfunction

function! ale_linters#bindzone#checkzone#Handle(buffer, lines) abort
    let l:warning_pattern = '\vzone example.com/IN: (.+)$'
    let l:error_pattern = '\v:(\d+): (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:error_pattern)
        let l:lnum = l:match[1]
        let l:text = l:match[2]

        call add(l:output, {'text': l:text, 'lnum': l:lnum + 0, 'type': 'E'})
    endfor

    for l:match in ale#util#GetMatches(a:lines, l:warning_pattern)
        let l:text = l:match[1]

        " Ignore information messages
        let l:scrub_match = matchlist(l:text, '\v(loaded serial|not loaded due to) ')

        if empty(l:scrub_match)
            call add(l:output, {'text': l:text, 'lnum': 0, 'type': 'W'})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('bindzone', {
\   'name': 'checkzone',
\   'executable': {b -> ale#Var(b, 'bindzone_checkzone_executable')},
\   'command': function('ale_linters#bindzone#checkzone#GetCommand'),
\   'callback': 'ale_linters#bindzone#checkzone#Handle',
\   'read_buffer': 0,
\})
