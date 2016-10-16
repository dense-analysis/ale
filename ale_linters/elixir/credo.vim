" Author: hauleth - https://github.com/haulethe

if exists('g:loaded_ale_linters_elixir_credo')
  finish
endif

let g:loaded_ale_linters_elixir_credo = 1

function! ale_linters#elixir#credo#Handle(buffer, lines)
  " Matches patterns line the following:
  "
  " file.go:27: missing argument for Printf("%s"): format reads arg 2, have only 1 args
  " file.go:53:10: if block ends with a return statement, so drop this else and outdent its block (move short variable declaration to its own line if necessary)
  " file.go:5:2: expected declaration, found 'STRING' "log"
  let l:pattern = '\v^stdin:(\d+):?(\d+)?: (.): (.+)$'
  let l:output = []

  for l:line in a:lines
    let l:match = matchlist(l:line, l:pattern)

    if len(l:match) == 0
        continue
    endif

    let l:type = l:match[3]
    let l:text = l:match[4]

    if l:type ==# 'C'
      let l:type = 'E'
    elseif l:type ==# 'R'
      let l:type = 'W'
    endif

    " vcol is Needed to indicate that the column is a character.
    call add(l:output, {
    \   'bufnr': a:buffer,
    \   'lnum': l:match[1] + 0,
    \   'vcol': 0,
    \   'col': l:match[2] + 0,
    \   'type': l:type,
    \   'text': l:text,
    \   'nr': -1,
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('elixir', {
      \ 'name': 'credo',
      \ 'executable': 'mix',
      \ 'command': 'mix credo suggest --format=flycheck --read-from-stdin',
      \ 'callback': 'ale_linters#elixir#credo#Handle',
      \ })
