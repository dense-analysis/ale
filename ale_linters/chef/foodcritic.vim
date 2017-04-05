" Author: Edward Larkey <edwlarkey@mac.com>
" Author: Jose Junior <jose.junior@gmail.com>
" Description: This file adds the foodcritic linter for Chef files.

" Support options!
let g:ale_chef_foodcritic_options = get(g:, 'ale_chef_foodcritic_options', '')
let g:ale_chef_foodcritic_executable = get(g:, 'ale_chef_foodcritic_executable', 'foodcritic')

function! ale_linters#chef#foodcritic#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " FC002: Avoid string interpolation where not required: httpd.rb:13
    let l:pattern = '^\(.\+:\s.\+\):\s\(.\+\):\(\d\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[1]

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[3] + 0,
        \   'col': 0,
        \   'text': l:text,
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

function! ale_linters#chef#foodcritic#GetCommand(buffer) abort
  return printf('%s %s %%t', 
  \   g:ale_chef_foodcritic_executable,
  \   escape(g:ale_chef_foodcritic_options, '~')
	\)
endfunction


call ale#linter#Define('chef', {
\   'name': 'foodcritic',
\   'executable': 'foodcritic',
\   'command_callback': 'ale_linters#chef#foodcritic#GetCommand',
\   'callback': 'ale_linters#chef#foodcritic#Handle',
\})

