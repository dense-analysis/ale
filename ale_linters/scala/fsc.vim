" Author: Nils Leuzinger - https://github.com/PawkyPenguin
" Description: Basic scala support using fsc
"
function! ale_linters#scala#fsc#GetExecutable(buffer) abort
    return ale#scala#GetExecutableForLinter(a:buffer, 'fsc')
endfunction

function! ale_linters#scala#fsc#GetCommand(buffer) abort
    return ale#scala#GetCommandForLinter(a:buffer, 'fsc')
endfunction

call ale#linter#Define('scala', {
\   'name': 'fsc',
\   'executable_callback': 'ale_linters#scala#fsc#GetExecutable',
\   'command_callback': 'ale_linters#scala#fsc#GetCommand',
\   'callback': 'ale#handlers#scala#HandleScalacLintFormat',
\   'output_stream': 'stderr',
\})
