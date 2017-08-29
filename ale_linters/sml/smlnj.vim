" Author: Paulo Alem <paulo.alem@gmail.com>, Jake Zimmerman <jake@zimmerman.io>
" Description: Rudimentary SML checking with smlnj compiler

" Let user manually set the CM file (in case our search for a CM file is
" ambiguous and picks the wrong one)
"
" See :help ale-sml-smlnj for more information.
call ale#Set('sml_smlnj_cm_file', '*.cm')

function! ale_linters#sml#smlnj#Handle(buffer, lines) abort
    " Try to match basic sml errors

    let l:out = []
    let l:pattern = '^.*\:\([0-9\.]\+\)\ \(\w\+\)\:\ \(.*\)'
    let l:pattern2 = '^.*\:\([0-9]\+\)\.\?\([0-9]\+\).* \(\(Warning\|Error\): .*\)'

    for l:line in a:lines
        let l:match2 = matchlist(l:line, l:pattern2)

        if len(l:match2) != 0
          call add(l:out, {
          \   'bufnr': a:buffer,
          \   'lnum': l:match2[1] + 0,
          \   'col' : l:match2[2] - 1,
          \   'text': l:match2[3],
          \   'type': l:match2[3] =~# '^Warning' ? 'W' : 'E',
          \})
          continue
        endif

        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) != 0
          call add(l:out, {
          \   'bufnr': a:buffer,
          \   'lnum': l:match[1] + 0,
          \   'text': l:match[2] . ': ' . l:match[3],
          \   'type': l:match[2] is# 'error' ? 'E' : 'W',
          \})
          continue
        endif

    endfor

    return l:out
endfunction

function! ale_linters#sml#smlnj#GetCommand(buffer) abort
  let l:pattern = ale#Var(a:buffer, 'sml_smlnj_cm_file')
  let l:as_list = 1

  let l:cmfile = ''
  for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
    let l:results = glob(l:pattern, 0, l:as_list)
    if len(l:results) > 0
      " If there is more than one CM file, we take the first one
      " See :help ale-sml-smlnj for how to configure this.
      let l:cmfile = l:results[0]
    endif
  endfor

  if l:cmfile ==# ''
    " No CM file found; default to checking just this file
    return 'sml %s < /dev/null'
  else
    " Found a CM file; let's use it
    return 'sml -m ' . l:cmfile . ' < /dev/null'
  endif
endfunction

call ale#linter#Define('sml', {
\   'name': 'smlnj',
\   'executable': 'sml',
\   'lint_file': 1,
\   'command_callback': 'ale_linters#sml#smlnj#GetCommand',
\   'callback': 'ale_linters#sml#smlnj#Handle',
\})
