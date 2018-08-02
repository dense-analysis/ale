" Author: w0rp <devw0rp@gmail.com>
" Description: A linter for checking ALE project code itself.

function! ale_linters#vim#ale_custom_linting_rules#GetExecutable(buffer) abort
    " Look for the custom-linting-rules script.
    return ale#path#FindNearestFile(a:buffer, 'test/script/custom-linting-rules')
endfunction

function! s:GetALEProjectDir(buffer) abort
    let l:executable = ale_linters#vim#ale_custom_linting_rules#GetExecutable(a:buffer)

    return ale#path#Dirname(ale#path#Dirname(ale#path#Dirname(l:executable)))
endfunction

function! ale_linters#vim#ale_custom_linting_rules#GetCommand(buffer) abort
    let l:dir = s:GetALEProjectDir(a:buffer)

    return ale#path#CdString(l:dir) . '%e .'
endfunction

function! ale_linters#vim#ale_custom_linting_rules#Handle(buffer, lines) abort
    let l:dir = s:GetALEProjectDir(a:buffer)
    let l:output = []
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+) (.+)$'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:filename = ale#path#GetAbsPath(l:dir, l:match[1])

        if bufnr(l:filename) is a:buffer
            call add(l:output, {
            \   'lnum': l:match[2],
            \   'text': l:match[3],
            \   'type': 'W',
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('vim', {
\   'name': 'ale_custom_linting_rules',
\   'executable_callback': 'ale_linters#vim#ale_custom_linting_rules#GetExecutable',
\   'command_callback': 'ale_linters#vim#ale_custom_linting_rules#GetCommand',
\   'callback': 'ale_linters#vim#ale_custom_linting_rules#Handle',
\   'lint_file': 1,
\})
