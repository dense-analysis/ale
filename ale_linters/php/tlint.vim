" Author: Jose Soto <jose@tighten.co>
"
" Description: Tighten Opinionated Linting

let g:ale_php_tlint_executable = get(g:, 'ale_php_tlint_executable', 'tlint')

function! ale_linters#php#tlint#GetCommand(buffer) abort
  return '%e lint %s'
endfunction

function! ale_linters#php#tlint#Handle(buffer, lines) abort
    " Matches against lines like the following:
    "
    " ! There should be 1 space around `.` concatenations, and additional lines should always start with a `.`
    " 22 : `        $something = 'a'.'name';`
    "
    let l:pattern = '^\(\d\+\) \:'
    let l:loopCount = 0
    let l:messagePattern = '^\! \(.*\)'
    let l:output = []
    let l:tempMessages = []

   for l:message in ale#util#GetMatches(a:lines, l:messagePattern)
    call add(l:tempMessages, l:message) 
   endfor

    let l:loopCount = 0
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:num = l:match[1]
        let l:text = l:tempMessages[l:loopCount]

        call add(l:output, {
        \   'lnum': l:num,
        \   'col': 0,
        \   'text': l:text,
        \   'type': 'W',
        \   'sub_type': 'style',
        \})

      let l:loopCount += 1
    endfor
    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'tlint',
\   'executable': {b -> ale#Var(b, 'php_tlint_executable')},
\   'command': function('ale_linters#php#tlint#GetCommand'),
\   'callback': 'ale_linters#php#tlint#Handle',
\})
