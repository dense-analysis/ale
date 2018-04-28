" Author: awlayton <alex@layton.in>
" Description: mlint for MATLAB files

let g:ale_matlab_mlint_executable =
\   get(g:, 'ale_matlab_mlint_executable', 'mlint')
let g:ale_matlab_mlint_options = get(g:, 'ale_matlab_mlint_options', '')
let g:ale_matlab_mlint_use_global = get(g:, 'ale_matlab_mlint_use_global', 0)

function! ale_linters#matlab#mlint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'matlab_mlint_executable')
endfunction

function! ale_linters#matlab#mlint#GetCommand(buffer) abort
    let l:executable = ale_linters#matlab#mlint#GetExecutable(a:buffer)
    
    if(ale#Var(a:buffer,'matlab_mlint_options') == '')
        return l:executable.' -id %t'
    else
        return l:executable.' '.ale#Var(a:buffer, 'matlab_mlint_options').' %t'
endfunction

function! ale_linters#matlab#mlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " L 27 (C 1): FNDEF: Terminate statement with semicolon to suppress output.
    " L 30 (C 13-15): FNDEF: A quoted string is unterminated.
    let l:pattern = '^L \(\d\+\) (C \([0-9-]\+\)): \([A-Z]\+\): \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:lnum = l:match[1] + 0
        let l:col = l:match[2] + 0
        let l:code = l:match[3]
        let l:text = l:match[4]

        " Suppress erroneous waring about filename
        " TODO: Enable this error when copying filename is supported
        if l:code is# 'FNDEF'
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:lnum,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('matlab', {
\   'name': 'mlint',
\   'executable_callback': 'ale_linters#matlab#mlint#GetExecutable',
\   'command_callback': 'ale_linters#matlab#mlint#GetCommand',
\   'output_stream': 'stderr',
\   'callback': 'ale_linters#matlab#mlint#Handle',
\})
