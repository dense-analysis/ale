" Author: Paul Monson <pmonson711@pm.me>
" Description: Expert integration (https://github.com/elixir-lang/expert)

call ale#Set('elixir_expert_release', 'expert')

function! ale_linters#elixir#expert#GetExecutable(buffer) abort
    let l:dir = ale#path#Simplify(ale#Var(a:buffer, 'elixir_expert_release'))

    return ale#path#FindNearestExecutable(a:buffer, [
    \ l:dir . '/expert_darwin_arm64',
    \ l:dir . '/expert_darwin_amd64',
    \ l:dir . '/expert_linux_amd64',
    \ l:dir . '\expert_windows_amd64',
    \])
endfunction

call ale#linter#Define('elixir', {
\   'name': 'expert',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#elixir#expert#GetExecutable'),
\   'command': function('ale_linters#elixir#expert#GetExecutable'),
\   'project_root': function('ale#handlers#elixir#FindMixUmbrellaRoot'),
\})
