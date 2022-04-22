" Author: Dalius Dobravolskas <dalius.dobravolskas@gmail.com>
" Description: VSCode json languageserver

function! ale_linters#json#vscodejson#GetProjectRoot(buffer) abort
    return fnamemodify(bufname(a:buffer), ':h')
endfunction

call ale#linter#Define('json', {
\   'name': 'vscodejson',
\   'lsp': 'stdio',
\   'executable': 'json-languageserver',
\   'command': '%e --stdio',
\   'project_root': function('ale_linters#json#vscodejson#GetProjectRoot'),
\})
