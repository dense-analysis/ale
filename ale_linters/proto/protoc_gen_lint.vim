" Author: Jeff Willette <jrwillette88@gmail.com>
" Description: run the protoc-gen-lint plugin for the protoc binary

function! ale_linters#proto#protoc_gen_lint#GetCommand(buffer) abort
    let l:dirname = expand('#' . a:buffer . ':p:h')
    let l:filename = expand('#' . a:buffer)

    "\   'command': 'protoc -I $(dirname %s) --lint_out=. %s',

    return 'protoc'
    \   . ' -I ' . ale#Escape(l:dirname)
    \   . ' --lint_out=. ' . ale#Escape(l:filename)
endfunction

call ale#linter#Define('proto', {
\   'name': 'protoc-gen-lint',
\   'lint_file': 1,
\   'output_stream': 'stderr',
\   'executable': 'protoc',
\   'command_callback': 'ale_linters#proto#protoc_gen_lint#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
