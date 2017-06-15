" Author: Jordan Andree <https://github.com/jordanandree>, David Alexander <opensource@thelonelyghost.com>
" Description: This file adds support for checking Crystal with crystal build

function! ale_linters#crystal#crystal#Handle(buffer, lines) abort
    let l:output = []

    let l:lines = join(a:lines, '')

    if !empty(l:lines)
      let l:errors = json_decode(l:lines)

      for l:error in l:errors
          call add(l:output, {
          \   'bufnr': a:buffer,
          \   'lnum': l:error.line + 0,
          \   'col': l:error.column + 0,
          \   'text': l:error.message,
          \   'type': 'E',
          \})
      endfor
    endif

    return l:output
endfunction

function! ale_linters#crystal#crystal#GetCommand(buffer) abort
    let l:crystal_cmd = 'crystal build -f json --no-codegen --no-color -o '
    let l:crystal_cmd .= ale#Escape(g:ale#util#nul_file)
    let l:crystal_cmd .= ' %s'

    return l:crystal_cmd
endfunction

call ale#linter#Define('crystal', {
\   'name': 'crystal',
\   'executable': 'crystal',
\   'output_stream': 'both',
\   'lint_file': 1,
\   'command_callback': 'ale_linters#crystal#crystal#GetCommand',
\   'callback': 'ale_linters#crystal#crystal#Handle',
\})
