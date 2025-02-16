function! ale_linters#html#djlint#Handle(buffer, lines)
  let l:output = []
  let l:pattern = '\v^([A-Z]\d+) (\d+):(\d+) (.*) (\<.*)$'
  let l:i = 0
  for l:match in ale#util#GetMatches(a:lines, l:pattern)
    let l:i += 1
    " echom l:i . ' match:' l:match[0]
    let l:item = {
          \   'lnum': l:match[2] + 0,
          \   'col': l:match[3] + 0,
          \   'vcol': 1,
          \   'text': l:match[4],
          \   'code': l:match[5],
          \   'type': 'W',
          \}
    call add(l:output, l:item)
  endfor
  return l:output
endfunction

call ale#linter#Define('html', {
\   'name': 'djlint',
\   'executable': 'djlint',
\   'command': 'djlint %s',
\   'callback': 'ale_linters#html#djlint#Handle',
\})
