" Author: carakan <carakan@gmail.com>
" Description: Fixing files with elixir formatter 'mix format'.

call ale#Set('elixir_mix_executable', 'mix')

function! ale#fixers#mix_format#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'elixir_mix_executable')
endfunction

function! ale#fixers#mix_format#Fix(buffer) abort
    return {
    \   'command': ale#Escape(ale#fixers#mix_format#GetExecutable(a:buffer))
    \       . ' format %t',
    \   'read_temporary_file': 1,
    \}
endfunction
