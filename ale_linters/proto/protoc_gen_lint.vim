" Author: Jeff Willette <jrwillette88@gmail.com>
" Description: run the protoc-gen-lint plugin for the protoc binary

function! ale_linters#proto#protoc_gen_lint#GetCommand(buffer) abort
    let l:dirname = expand('#' . a:buffer . ':p:h')

    return 'protoc'
    \   . ' -I ' . ale#Escape(l:dirname)
    \   . ' --lint_out=. ' . '%s'
endfunction

call ale#linter#Define('proto', {
\   'name': 'protoc-gen-lint',
\   'lint_file': 1,
\   'output_stream': 'stderr',
\   'executable': 'protoc',
\   'command_callback': 'ale_linters#proto#protoc_gen_lint#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
