" Author: Andrew Balmos - <andrew@balmos.org>
" Description: lacheck for LaTeX files

let g:ale_tex_lacheck_executable =
\   get(g:, 'ale_tex_lacheck_executable', 'lacheck')

function! ale_linters#tex#lacheck#Handle(buffer, lines) abort
  " Mattes lines like:
  "
  " "book.tex", line 37: possible unwanted space at "{"
  " "book.tex", line 38: missing `\ ' after "etc."

  let l:pattern = '^".\+", line \(\d\+\): \(.\+\)$'
  let l:output = []

  for l:line in a:lines
    let l:match = matchlist(l:line, l:pattern)

    if len(l:match) == 0
      continue
    endif

    " lacheck follows `\input{}` commands. If the cwd is not the same as the
    " file in the buffer then it will fail to find the inputed items. We do not
    " want warnings from those items anyway
    if !empty(matchstr(l:match[2], '^Could not open ".\+"$'))
      continue
    endif

    call add(l:output, {
    \   'bufnr': a:buffer,
    \   'lnum': l:match[1] + 0,
    \   'vcol': 0,
    \   'col': 0,
    \   'text': l:match[2],
    \   'type': 'W',
    \   'nr': -1
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('tex', {
\   'name': 'lacheck',
\   'executable': 'lacheck',
\   'command': g:ale#util#stdin_wrapper . ' .tex '
\      . g:ale_tex_lacheck_executable,
\   'callback': 'ale_linters#tex#lacheck#Handle'
\})
