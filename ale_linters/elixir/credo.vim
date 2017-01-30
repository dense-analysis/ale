" Author: hauleth - https://github.com/hauleth

function! ale_linters#elixir#credo#Handle(buffer, lines) abort
  " Matches patterns line the following:
  "
  " stdin:19: F: Pipe chain should start with a raw value.
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
      \ 'callback': 'ale_linters#elixir#credo#Handle' })
