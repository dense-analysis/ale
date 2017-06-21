" Author: Vincent Lequertier <https://github.com/SkySymbol>, Chris Weyl <cweyl@alumni.drew.edu>
" Description: This file adds support for checking perl with perl critic

let g:ale_perl_perlcritic_executable =
\   get(g:, 'ale_perl_perlcritic_executable', 'perlcritic')

let g:ale_perl_perlcritic_profile =
\   get(g:, 'ale_perl_perlcritic_profile', '.../.perlcriticrc')

let g:ale_perl_perlcritic_options =
\   get(g:, 'ale_perl_perlcritic_options', '')

let g:ale_perl_perlcritic_showrules =
\   get(g:, 'ale_perl_perlcritic_showrules', 0)

function! ale_linters#perl#perlcritic#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'perl_perlcritic_executable')
endfunction

function! ale_linters#perl#perlcritic#GetCommand(buffer) abort
    let l:critic_verbosity = '%l:%c %m\n'
    if ale#Var(a:buffer, 'perl_perlcritic_showrules')
        let l:critic_verbosity = '%l:%c %m [%p]\n'
    endif

    return ale_linters#perl#perlcritic#GetExecutable(a:buffer)
    \   . " --verbose '". l:critic_verbosity . "' --nocolor"
    \   . " --profile " . ale#Var(a:buffer, 'perl_perlcritic_profile') . ' '
    \   . ale#Var(a:buffer, 'perl_perlcritic_options')
endfunction


function! ale_linters#perl#perlcritic#Handle(buffer, lines) abort
    let l:pattern = '\(\d\+\):\(\d\+\) \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'col': l:match[2],
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('perl', {
\   'name': 'perlcritic',
\   'output_stream': 'stdout',
\   'executable_callback': 'ale_linters#perl#perlcritic#GetExecutable',
\   'command_callback': 'ale_linters#perl#perlcritic#GetCommand',
\   'callback': 'ale_linters#perl#perlcritic#Handle',
\})
