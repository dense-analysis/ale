" Author: Evan Chen <evan@evanchen.cc>
" Description: Fast Markdown linter and formatter written in Rust


call ale#Set('markdown_rumdl_executable', 'rumdl')

function! ale_linters#markdown#rumdl#GetProjectRoot(buffer) abort
  let l:dotconfig = ale#path#FindNearestFile(a:buffer, '.rumdl.toml')
  let l:config = ale#path#FindNearestFile(a:buffer, 'rumdl.toml')

  if !empty(l:dotconfig) || !empty(l:config)
    let l:nearest = len(l:dotconfig) >= len(l:config) ? l:dotconfig : l:config
    return fnamemodify(l:nearest, ':h')
  endif

  let l:project_root = finddir('.git/..', fnamemodify(bufname(a:buffer), ':p:h') . ';')

  if !empty(l:project_root)
    return l:project_root
  endif

  return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

call ale#linter#Define('markdown', {
\   'name': 'rumdl',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'markdown_rumdl_executable')},
\   'command': '%e server --stdio',
\   'project_root': function('ale_linters#markdown#rumdl#GetProjectRoot'),
\   'language': 'markdown',
\})
