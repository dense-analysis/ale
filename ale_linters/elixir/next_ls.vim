" Author: Mitchell Hanberg <mitch@mitchellhanberg.com>
" Description: Next LS  (https://github.com/elixir-tools/next-ls)

call ale#Set('elixir_next_ls_executable', 'nextls')
call ale#Set('elixir_next_ls_options', '--stdio')

function! ale_linters#elixir#next_ls#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'elixir_next_ls_options'))
endfunction

call ale#linter#Define('elixir', {
\   'name': 'next_ls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'elixir_next_ls_executable')},
\   'command': function('ale_linters#elixir#next_ls#GetCommand'),
\   'project_root': function('ale#handlers#elixir#FindMixUmbrellaRoot'),
\})
