" Author: Francis Agyapong <francisagyapong2@gmail.com>
" Description: Lint kotlin files using ktlint

let g:ale_kotlin_ktlint_exec = get(g:, 'ale_kotlin_ktlint_exec', 'ktlint')
let g:ale_kotlin_ktlint_rulesets = get(g:, 'ale_kotlin_ktlint_rulesets', [])
let g:ale_kotlin_ktlint_format = get(g: , 'ale_kotlin_ktlint_format', 0)
let g:ale_kotlin_ktlint_config_file = get(g:, 'ale_kotlin_ktlint_config_file', '.ale_kotlin_ktlint_config')
let g:ale_kotlin_ktlint_enable_config = get(g:, 'ale_kotlin_ktlint_enable_config', 0)


function! ale_linters#kotlin#ktlint#GetCommand(buffer) abort
    if ale#Var(a:buffer, 'kotlin_ktlint_enable_config')
        let l:config_file = ale#path#FindNearestFile(a:buffer, ale#Var(a:buffer, 'kotlin_ktlint_config_file'))
        if !empty(l:config_file) && filereadable(l:config_file)
            execute 'source ' . l:config_file
        endif
    endif

    let l:exec = ale#Var(a:buffer, 'kotlin_ktlint_exec')
    let l:file_path = expand('#' . a:buffer . ':p')
    let l:options = ''

    " Formmatted content written to original file, not sure how to handle
    " if ale#Var(a:buffer, 'kotlin_ktlint_format')
    "     let l:options = l:options . ' --format'
    " endif

    for l:ruleset in ale#Var(a:buffer, 'kotlin_ktlint_rulesets')
        let l:options = l:options . ' --ruleset ' . l:ruleset
    endfor

    return l:exec . ' ' . l:options . ' ' . l:file_path
endfunction

function! ale_linters#kotlin#ktlint#Handle(buffer, lines) abort
    let l:message_pattern = '^\(.*\):\([0-9]\+\):\([0-9]\+\):\s\+\(.*\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:message_pattern)

        if len(l:match) == 0
            continue
        endif

        let l:file = l:match[1]
        let l:line = l:match[2] + 0
        let l:column = l:match[3] + 0
        let l:text = l:match[4]

        let l:buf_abspath = fnamemodify(l:file, ':p')
        let l:type = l:text =~? 'not a valid kotlin file' ? 'E' : 'W'

        call add(l:output, {
            \ 'lnum': l:line,
            \ 'col': l:column,
            \ 'text': l:text,
            \ 'type': l:type
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('kotlin', {
    \   'name': 'ktlint',
    \   'executable': 'ktlint',
    \   'command_callback': 'ale_linters#kotlin#ktlint#GetCommand',
    \   'callback': 'ale_linters#kotlin#ktlint#Handle',
    \   'lint_file': 1
\})
