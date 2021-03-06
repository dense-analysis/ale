" Author: Risto Stevcev <me@risto.codes>
" Description: The official language server for OCaml

call ale#Set('reason_ocamllsp_use_opam', 0)
call ale#Set('reason_ocamllsp_use_esy', 1)

call ale#linter#Define('reason', {
\   'name': 'ocamllsp',
\   'lsp': 'stdio',
\   'executable': function('ale#handlers#ocamllsp#GetExecutable'),
\   'command': function('ale#handlers#ocamllsp#GetCommand'),
\   'language': function('ale#handlers#ocamllsp#GetLanguage'),
\   'project_root': function('ale#handlers#ocamllsp#GetProjectRoot'),
\})
