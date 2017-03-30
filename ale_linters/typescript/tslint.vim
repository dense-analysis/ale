" Author: Prashanth Chandra https://github.com/prashcr
" Description: tslint for TypeScript files

let g:ale_typescript_tslint_executable =
\   get(g:, 'ale_typescript_tslint_executable', 'tslint')

let g:ale_typescript_tslint_config_path =
\   get(g:, 'ale_typescript_tslint_config_path', '')

function! ale_linters#typescript#tslint#GetExecutable(buffer) abort
    return ale#util#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/tslint',
    \   g:ale_typescript_tslint_executable
    \)
endfunction

function! ale_linters#typescript#tslint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " hello.ts[7, 41]: trailing whitespace
    " hello.ts[5, 1]: Forbidden 'var' keyword, use 'let' or 'const' instead
    "
    let l:ext = '.' . fnamemodify(bufname(a:buffer), ':e')
    let l:pattern = '.\+' . l:ext . '\[\(\d\+\), \(\d\+\)\]: \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:line = l:match[1] + 0
        let l:column = l:match[2] + 0
        let l:type = 'E'
        let l:text = l:match[3]

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:line,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#typescript#tslint#BuildLintCommand(buffer) abort
    let g:ale_typescript_tslint_config_path =
    \   empty(g:ale_typescript_tslint_config_path)
    \   ? ale#util#FindNearestFile(a:buffer, 'tslint.json')
    \   : g:ale_typescript_tslint_config_path

    let l:tslint_options =
    \   empty(g:ale_typescript_tslint_config_path)
    \   ? ''
    \   : '-c ' . fnameescape(g:ale_typescript_tslint_config_path)

    return ale_linters#typescript#tslint#GetExecutable(a:buffer)
    \   . ' ' . l:tslint_options
    \   . ' %t'
endfunction

call ale#linter#Define('typescript', {
\   'name': 'tslint',
\   'executable_callback': 'ale_linters#typescript#tslint#GetExecutable',
\   'command_callback': 'ale_linters#typescript#tslint#BuildLintCommand',
\   'callback': 'ale_linters#typescript#tslint#Handle',
\})
