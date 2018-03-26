" Author: Zoltan Kalmar - https://github.com/kalmiz,
"         w0rp <devw0rp@gmail.com>
" Description: Basic scala support using scalac

function! ale_linters#scala#scalac#GetExecutable(buffer) abort
    return ale#scala#GetExecutableForLinter(a:buffer, 'scalac')
endfunction

function! ale_linters#scala#scalac#GetCommand(buffer) abort
    return ale#scala#GetCommandForLinter(a:buffer, 'scalac')
endfunction

call ale#linter#Define('scala', {
\   'name': 'scalac',
\   'executable_callback': 'ale_linters#scala#scalac#GetExecutable',
\   'command_callback': 'ale_linters#scala#scalac#GetCommand',
\   'callback': 'ale#handlers#scala#HandleScalacLintFormat',
\   'output_stream': 'stderr',
\})
