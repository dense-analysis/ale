" Author: Ivan Stone <istone@snap.com>
" Description: LSP linter for Erlang files using erlang-language-platform

call ale#Set('erlang_elp_executable', 'elp')

function! s:FindProjectRoot(buffer) abort
    let l:markers = [
    \   '_checkouts/',
    \   '_build/',
    \   'deps/',
    \   'rebar.config',
    \   'rebar.lock',
    \   'erlang.mk',
    \   '.kerl_config',
    \]

    for l:marker in l:markers
        let l:path = l:marker[-1:] is# '/'
        \   ? ale#path#FindNearestDirectory(a:buffer, l:marker)
        \   : ale#path#FindNearestFile(a:buffer, l:marker)

        if !empty(l:path)
            return ale#path#Dirname(l:path)
        endif
    endfor

    return ''
endfunction

call ale#linter#Define('erlang', {
\   'name': 'elp',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'erlang_elp_executable')},
\   'command': '%e server',
\   'project_root': function('s:FindProjectRoot'),
\})
