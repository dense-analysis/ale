""" Author: Fran Casas - https://github.com/franciscoj

let g:ale_elixir_mix_command = get(g:, 'ale_elixir_mix_command', 'mix compile')
let g:ale_elixir_mix_options = get(g:, 'ale_elixir_mix_options', '')

function! ale_linters#elixir#mix#Handle(buffer, lines) abort
    let l:messages = ale_linters#elixir#mix#Preproces(a:lines)

    let l:warning_pattern = '\vwarning: (.*)\n  (.*):(\d*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(l:messages["warnings"], l:warning_pattern)
      if bufname(a:buffer) == l:match[2]
        call add(l:output, {
        \    'bufnr': a:buffer,
        \    'lnum': l:match[3] + 0,
        \    'col': 0,
        \    'type': 'W',
        \    'text': l:match[1],
        \})
      endif
    endfor

    let l:error_pattern = '** (CompileError) \(.*\):\(\d*\): \(.*\)'

    for l:match in ale#util#GetMatches(l:messages["errors"], l:error_pattern)
      if bufname(a:buffer) == l:match[1]
        call add(l:output, {
        \    'bufnr': a:buffer,
        \    'lnum': l:match[2] + 0,
        \    'col': 0,
        \    'type': 'E',
        \    'text': l:match[3],
        \})
      endif
    endfor

    return l:output
endfunction

" Elixir warnings come in the following format:
" warning: function my_function/0 is unused
"   lib/with_warn.ex:25
"
" This process the 2 lines into a single string so that they can be easily
" matched.
"
" It also cleans up the errors which come on the following format
" ** (CompileError) lib/with_more_warns.ex:1: undefined function defmodule/1
function! ale_linters#elixir#mix#Preproces(lines) abort
  let l:index = 0
  let l:warnings = []
  let l:errors = []

  while l:index < len(a:lines)
    let l:line = get(a:lines, l:index)

    if l:line =~ '^warning: .*$'
      let l:next_line = get(a:lines, l:index + 1)
      let l:full_warning = l:line . "\n" . l:next_line

      call add(l:warnings, l:full_warning)
    endif

    if l:line =~ '** (CompileError)'
      call add(l:errors, l:line)
    endif

    let l:index = l:index + 1
  endwhile

  return {
  \    'errors': l:errors,
  \    'warnings': l:warnings
  \}
endfunction

function! ale_linters#elixir#mix#GetCommand(buffer) abort
  return ale#Var(a:buffer, 'elixir_mix_command')
  \    . ' --warnings-as-errors'
  \    . ' --force'
  \    . ale#Var(a:buffer, 'elixir_mix_options')
  \    . ' 2>&1'
endfunction

call ale#linter#Define('elixir', {
\   'name': 'mix',
\   'executable': 'mix',
\   'command_callback': 'ale_linters#elixir#mix#GetCommand',
\   'callback': 'ale_linters#elixir#mix#Handle',
\})

