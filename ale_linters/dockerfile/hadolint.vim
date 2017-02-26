" Author: hauleth - https://github.com/hauleth

function! ale_linters#dockerfile#hadolint#Handle(buffer, lines) abort
  " Matches patterns line the following:
  "
  " stdin:19: F: Pipe chain should start with a raw value.
  let l:pattern = '\v^/dev/stdin:?(\d+)? (\S+) (.+)$'
  let l:output = []

  for l:line in a:lines
    let l:match = matchlist(l:line, l:pattern)

    if len(l:match) == 0
        continue
    endif

    let l:lnum = 0

    if l:match[1] !=# ''
        let l:lnum = l:match[1] + 0
    endif

    let l:type = 'W'
    let l:text = l:match[3]

    " vcol is Needed to indicate that the column is a character.
    call add(l:output, {
    \   'bufnr': a:buffer,
    \   'lnum': l:lnum,
    \   'col': 0,
    \   'type': l:type,
    \   'text': l:text,
    \   'nr': l:match[2],
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('dockerfile', {
      \ 'name': 'hadolint',
      \ 'executable': 'hadolint',
      \ 'command': 'hadolint -',
      \ 'callback': 'ale_linters#dockerfile#hadolint#Handle' })
