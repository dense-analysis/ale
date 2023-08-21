scriptencoding utf-8
" Author: Peter Benjamin <https://github.com/pbnj>
" Description: Define a handler function for gitleaks

call ale#Set('gitleaks_executable', 'gitleaks')
call ale#Set('gitleaks_options', '')

function! ale#handlers#gitleaks#GetCommand(buffer) abort
    return '%e'
    \   . ' detect --no-git --no-color --no-banner --redact --verbose --source=%s'
    \   . ale#Pad(ale#Var(a:buffer, 'gitleaks_options'))
endfunction

function! ale#handlers#gitleaks#Handle(buffer, lines) abort
    " Look for lines like the following:
    "
    " Finding:     ACCESS_KEY_ID=REDACTED
    " Secret:      REDACTED
    " RuleID:      generic-api-key
    " Entropy:     3.546594
    " File:        tmp/env
    " Line:        1
    " Fingerprint: tmp/env:generic-api-key:1
    let l:pattern = '\v^Fingerprint: .*:(.*):(\d+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'text': l:match[1],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#gitleaks#DefineLinter(filetype) abort
    call ale#Set('gitleaks_executable', 'gitleaks')
    call ale#Set('gitleaks_options', '')

    call ale#linter#Define(a:filetype, {
    \   'name': 'gitleaks',
    \   'executable': {b -> ale#Var(b, 'gitleaks_executable')},
    \   'command': function('ale#handlers#gitleaks#GetCommand'),
    \   'callback': 'ale#handlers#gitleaks#Handle',
    \   'lint_file': 1,
    \})
endfunction
