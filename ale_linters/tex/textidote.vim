" Author: Jordi Altayo <jordiag@kth.se>, Juan Pablo Stumpf
" <juanolon@gmail.com>
" Description: support for textidote grammar and syntax checker

call ale#Set('tex_textidote_executable', 'textidote')
call ale#Set('tex_textidote_options', '--no-color --output singleline')
" TODO get language from spell spelllang
call ale#Set('tex_textidote_check_lang', '')


function! ale_linters#tex#textidote#GetExecutable(buffer) abort
    let l:exe = ale#Var(a:buffer, 'tex_textidote_executable')
    let l:exe .= ' ' . ale#Var(a:buffer, 'tex_textidote_options')

    let l:check_lang = ale#Var(a:buffer, 'tex_textidote_check_lang')
    if !empty(l:check_lang)
        let l:exe .= ' --check ' . l:check_lang
    endif

    return l:exe . ' ' . expand('%')
endfunction

function! ale_linters#tex#textidote#Handle(buffer, lines) abort
    let l:pattern = '.*' . expand('%:t:r') . '\.tex(L\(\d\+\)C\(\d\+\)-L\d\+C\d\+): \(.*\)".*"'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col' : l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('tex', {
\   'name': 'textidote',
\   'output_stream': 'stdout',
\   'executable': {b -> ale#Var(b, 'tex_textidote_executable')},
\   'command': function('ale_linters#tex#textidote#GetExecutable'),
\   'callback': 'ale_linters#tex#textidote#Handle',
\})

