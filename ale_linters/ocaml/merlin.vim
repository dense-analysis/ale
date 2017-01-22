" Author: Andrey Popp -- @andreypopp
" Description: Report errors in OCaml code with Merlin

if !exists('g:merlin')
  finish
endif

function! ale_linters#ocaml#merlin#Handle(buffer, lines) abort
  let l:errors = merlin#ErrorLocList()
  return l:errors
endfunction

call ale#linter#Define('ocaml', {
\   'name': 'merlin',
\   'executable': 'ocamlmerlin',
\   'command': 'true',
\   'callback': 'ale_linters#ocaml#merlin#Handle',
\})

