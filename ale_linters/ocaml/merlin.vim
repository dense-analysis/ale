" Author: Andrey Popp -- @andreypopp
" Description: Report errors in OCaml code with Merlin

if !exists('g:merlin')
  echo 'Error: merlin vim bindings are required for Ale merlin linter to work'
  finish
endif

function! ale_linters#ocaml#merlin#Handle(buffer, lines)
  let l:errors = merlin#ErrorLocList()
  return l:errors
endfunction

call ale#linter#Define('ocaml', {
\   'name': 'merlin',
\   'executable': 'ocamlmerlin',
\   'command': 'true',
\   'callback': 'ale_linters#ocaml#merlin#Handle',
\})

