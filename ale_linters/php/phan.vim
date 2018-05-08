" Author: diegoholiveira <https://github.com/diegoholiveira>, haginaga
" Description: static analyzer for PHP

" Define the minimum severity
let g:ale_php_phan_minimum_severity = get(g:, 'ale_php_phan_minimum_severity', 0)

let g:ale_php_phan_executable = get(g:, 'ale_php_phan_executable', 'phan')
let g:ale_php_phan_use_client = get(g:, 'ale_php_phan_use_client', 0)

function! ale_linters#php#phan#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'php_phan_executable')
endfunction

function! ale_linters#php#phan#GetCommand(buffer) abort
    let l:use_client = ale#Var(a:buffer, 'php_phan_use_client')
    if l:use_client == 1
        let l:args = '-l '
        \   . ' %s'
    else
        let l:args = '-y '
        \   . ale#Var(a:buffer, 'php_phan_minimum_severity')
        \   . ' %s'
    endif

    let l:executable = ale_linters#php#phan#GetExecutable(a:buffer)

    return ale#Escape(l:executable) . ' ' . l:args
endfunction

function! ale_linters#php#phan#Handle(buffer, lines) abort
    let l:use_client = ale#Var(a:buffer, 'php_phan_use_client')

    " Matches against lines like the following:
    if l:use_client == 1
        " Phan error: ERRORTYPE: message in /path/to/some-filename.php on line nnn
        let l:pattern = '^Phan error: \(\w\+\): \(.\+\) in \(.\+\) on line \(\d\+\)$'
    else
        " /path/to/some-filename.php:18 ERRORTYPE message
        let l:pattern = '^.*:\(\d\+\)\s\(\w\+\)\s\(.\+\)$'
    endif

    let l:output = []
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:use_client == 1
            let l:dict = {
            \   'lnum': l:match[4] + 0,
            \   'text': l:match[2],
            \   'type': 'W',
            \}
        else
            let l:dict = {
            \   'lnum': l:match[1] + 0,
            \   'text': l:match[3],
            \   'type': 'W',
            \}
        endif

        call add(l:output, l:dict)
    endfor

    return l:output
endfunction

call ale#linter#Define('php', {
\   'name': 'phan',
\   'executable_callback': 'ale_linters#php#phan#GetExecutable',
\   'command_callback': 'ale_linters#php#phan#GetCommand',
\   'callback': 'ale_linters#php#phan#Handle',
\})
