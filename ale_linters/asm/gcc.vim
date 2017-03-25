" Author: Lucas Kolstad <lkolstad@uw.edu>
" Description: gcc linter for asm files

let g:ale_asm_gcc_options =
\   get(g:, 'ale_asm_gcc_options', '-Wall')

function! ale_linters#asm#gcc#GetCommand(buffer) abort
  return 'gcc -x assembler -fsyntax-only '
  \    . '-iquote ' . fnameescape(fnamemodify(bufname(a:buffer), ':p:h'))
  \    . ' ' . g:ale_asm_gcc_options . ' -'
endfunction

function! ale_linters#asm#gcc#Handle(buffer, lines) abort
  let l:pattern = '^.\+:\(\d\+\): \([^:]\+\): \(.\+\)$'
  let l:output = []

  for l:line in a:lines
    let l:match = matchlist(l:line, l:pattern)

    if len(l:match) == 0
      continue
    endif

    call add(l:output, {
    \ 'bufnr': a:buffer,
    \ 'lnum': l:match[1] + 0,
    \ 'vcol': 0,
    \ 'col': 0,
    \ 'text': l:match[3],
    \ 'type': l:match[2] =~? 'error' ? 'E' : 'W',
    \ 'nr': -1,
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('asm', {
\    'name': 'gcc',
\    'output_stream': 'stderr',
\    'executable': 'gcc',
\    'command_callback': 'ale_linters#asm#gcc#GetCommand',
\    'callback': 'ale_linters#asm#gcc#Handle',
\})
