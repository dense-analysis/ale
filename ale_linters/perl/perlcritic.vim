" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl with perl critic

if !exists('g:ale_perl_perlcritic_showrules')
    let g:ale_perl_perlcritic_showrules = 0
endif

function! ale_linters#perl#perlcritic#GetCommand(buffer) abort
    let l:critic_verbosity = '%l:%c %m\n'
    if g:ale_perl_perlcritic_showrules
        let l:critic_verbosity = '%l:%c %m [%p]\n'
    endif

    return "perlcritic --verbose '". l:critic_verbosity . "' --nocolor"
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
\   'executable': 'perlcritic',
\   'output_stream': 'stdout',
\   'command_callback': 'ale_linters#perl#perlcritic#GetCommand',
\   'callback': 'ale_linters#perl#perlcritic#Handle',
\})
