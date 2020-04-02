" Author: Akiomi Kamakura <akiomik@gmail.com>
" Description: Lint Agda files with Agda

call ale#Set('agda_agda_executable', 'agda')

function! ale_linters#agda#agda#RunWithVersionCheck(buffer) abort
    let l:executable = ale#Var(a:buffer, 'agda_agda_executable')
    let l:command = ale#Escape(l:executable) . ' --version'

    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   l:executable,
    \   l:command,
    \   function('ale_linters#agda#agda#GetCommand'),
    \)
endfunction

function! ale_linters#agda#agda#GetCommand(buffer, version) abort
    if ale#semver#GTE(a:version, [2, 5, 1])
        return "echo 'IOTCM \"%t\" None Indirect (Cmd_load \"%t\" [])'"
        \ . ' | %e --interaction'
    endif

    return 0
endfunction

function! ale_linters#agda#agda#HandleMessages(buffer, positionLine, messageLines, type) abort
    let l:matches = ale#util#GetMatches(a:positionLine, '\v:(\d+),(\d+)-(\d+)')

    if len(l:matches) == 0
        return {}
    endif

    let l:match = l:matches[0]

    return {
    \   'lnum': str2nr(l:match[1]),
    \   'col': str2nr(l:match[2]),
    \   'end_col': str2nr(l:match[3]),
    \   'text': join(a:messageLines, ' '),
    \   'type': a:type,
    \}
endfunction

function! ale_linters#agda#agda#HandleErrors(buffer, label, message) abort
    let l:lines = split(a:message, '\\n')

    if l:lines[0] !~# '^———— Error ————'
        let l:type = a:label is# 'Error' ? 'E' : 'W'

        return [ale_linters#agda#agda#HandleMessages(a:buffer, l:lines[0], l:lines[1:], l:type)]
    endif

    let l:output = []
    let l:blocks = split(a:message, '\\n\\n')
    let l:errorLines = split(l:blocks[0], '\\n')
    call add(l:output, ale_linters#agda#agda#HandleMessages(a:buffer, l:errorLines[1], l:errorLines[2:], 'E'))

    if len(l:blocks) == 2
        let l:warnLines = split(l:blocks[1], '\\n')
        call add(l:output, ale_linters#agda#agda#HandleMessages(a:buffer, l:warnLines[1], l:warnLines[2:], 'W'))
    endif

    return l:output
endfunction

function! ale_linters#agda#agda#HandleGoals(buffer, label, message) abort
    let l:output = []
    let l:blocks = split(a:message, '\\n\\n')

    if len(l:blocks) == 1
        let l:messageLines = []
        let l:type = 'I'
    else
        let l:messageLines = split(l:blocks[1], '\\n')[1:]
        let l:type = 'E'
    endif

    let l:positionLines = split(substitute(l:blocks[0], '\\n$', '', ''), '\\n')

    for l:positionLine in l:positionLines
        let l:result = ale_linters#agda#agda#HandleMessages(a:buffer, l:positionLine, l:messageLines, l:type)

        if !empty(l:result)
            call add(l:output, l:result)
        endif
    endfor

    return l:output
endfunction

function! ale_linters#agda#agda#Handle(buffer, lines) abort
    let l:pattern = '\v^(Agda2\>\s*)?\(agda2-info-action "\*(Error|All Errors|All Goals|All Goals, Errors)\*" "(.*)" (t|nil)\)$'

    for l:line in a:lines
        let l:matches = ale#util#GetMatches(l:line, l:pattern)

        if len(l:matches) == 0
            continue
        endif

        let l:match = l:matches[0]

        if l:match[2] is# 'Error' || l:match[2] is# 'All Errors'
            return ale_linters#agda#agda#HandleErrors(a:buffer, l:match[2], l:match[3])
        elseif l:match[2] is# 'All Goals' || l:match[2] is# 'All Goals, Errors'
            return ale_linters#agda#agda#HandleGoals(a:buffer, l:match[2], l:match[3])
        endif
    endfor

    return []
endfunction

call ale#linter#Define('agda', {
\   'name': 'agda',
\   'executable': {b -> ale#Var(b, 'agda_agda_executable')},
\   'command': function('ale_linters#agda#agda#RunWithVersionCheck'),
\   'output_stream': 'stdout',
\   'callback': 'ale_linters#agda#agda#Handle',
\})
