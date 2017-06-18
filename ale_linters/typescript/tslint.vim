" Author: Prashanth Chandra https://github.com/prashcr
" Description: tslint for TypeScript files

call ale#Set('typescript_tslint_executable', 'tslint')
call ale#Set('typescript_tslint_config_path', '')
call ale#Set('typescript_tslint_use_global', 0)

function! ale_linters#typescript#tslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'typescript_tslint', [
    \   'node_modules/.bin/tslint',
    \])
endfunction

function! ale_linters#typescript#tslint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " WARNING: hello.ts[113, 6]: Unnecessary semicolon
    " ERROR: hello.ts[133, 10]: Missing semicolon

    let l:ext = '.' . fnamemodify(bufname(a:buffer), ':e')
    let l:pattern = '\<\(WARNING\|ERROR\)\>: .\+' . l:ext . '\[\(\d\+\), \(\d\+\)\]: \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:type = l:match[1]
        let l:line = l:match[2] + 0
        let l:column = l:match[3] + 0
        let l:text = l:match[4]

        call add(l:output, {
        \   'type': (l:type ==# 'WARNING' ? 'W' : 'E'),
        \   'lnum': l:line,
        \   'col': l:column,
        \   'text': l:text,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#typescript#tslint#BuildLintCommand(buffer) abort
    let l:tslint_config_path = ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'tslint.json',
    \   ale#Var(a:buffer, 'typescript_tslint_config_path')
    \)

    let l:tslint_config_option = !empty(l:tslint_config_path)
    \   ? '-c ' . ale#Escape(l:tslint_config_path)
    \   : ''

    return ale_linters#typescript#tslint#GetExecutable(a:buffer)
    \   . ' ' . l:tslint_config_option
    \   . ' %t'
endfunction

call ale#linter#Define('typescript', {
\   'name': 'tslint',
\   'executable_callback': 'ale_linters#typescript#tslint#GetExecutable',
\   'command_callback': 'ale_linters#typescript#tslint#BuildLintCommand',
\   'callback': 'ale_linters#typescript#tslint#Handle',
\})
