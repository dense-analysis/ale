" Author: Michel Lang <michellang@gmail.com>, w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking R code with lintr.

function! ale_linters#r#lintr#GetCommand(buffer) abort
    return ale#path#BufferCdString(a:buffer)
    \   . 'Rscript -e ' . ale#Escape('lintr::lint(commandArgs(TRUE))') . ' %t'
endfunction

call ale#linter#Define('r', {
\   'name': 'lintr',
\   'executable': 'Rscript',
\   'command_callback': 'ale_linters#r#lintr#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'output_stream': 'both',
\})
