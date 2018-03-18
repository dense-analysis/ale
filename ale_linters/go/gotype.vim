" Author: Jelte Fennema <github-public@jeltef.nl>
" Description: gotype for Go files

function! ale_linters#go#gotype#GetCommand(buffer) abort
    if expand('#' . a:buffer . ':p') =~# '_test\.go$'
        return
    endif

    return 'gotype %s'
endfunction

call ale#linter#Define('go', {
\   'name': 'gotype',
\   'output_stream': 'stderr',
\   'executable': 'gotype',
\   'command_callback': 'ale_linters#go#gotype#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\   'lint_file': 1,
\})
