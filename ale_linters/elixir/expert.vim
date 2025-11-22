" Author: Paul Monson <pmonson711@pm.me>
" Description: Expert integration (https://github.com/elixir-lang/expert)

call ale#Set('elixir_expert_executable', 'expert')

call ale#linter#Define('elixir', {
\   'name': 'expert',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'elixir_expert_executable')},
\   'command': '%e',
\   'project_root': function('ale#handlers#elixir#FindMixUmbrellaRoot'),
\})
