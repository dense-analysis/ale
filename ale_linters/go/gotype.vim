" Author: Jelte Fennema <github-public@jeltef.nl>
" Description: gotype for Go files

call ale#linter#Define('go', {
\   'name': 'gotype',
\   'output_stream': 'stderr',
\   'executable': 'gotype',
\   'command_callback': 'ale_linters#go#gotype#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})

"\   'command':
function! ale_linters#go#gotype#GetCommand(buffer) abort
    let l:cur_file = expand('#' . a:buffer . ':p')
    if l:cur_file =~# '_test\.go$'
        return
    endif

    let l:module_files = globpath(expand('#' . a:buffer . ':p:h'), '*.go', 0, 1)
    let l:other_module_files = filter(l:module_files, 'v:val isnot# ' . ale#util#EscapeVim(l:cur_file) . ' && v:val !~# "_test\.go$"')
    return 'gotype %t ' . join(map(l:other_module_files, 'ale#Escape(v:val)'))

endfunction
