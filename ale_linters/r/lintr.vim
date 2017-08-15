" Author: Michel Lang <michellang@gmail.com>, w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking R code with lintr.

let g:ale_r_lintr_options =
\   get(g:, 'ale_r_lintr_options', 'lintr::with_defaults()')
" A reasonable alternative default:
" \   get(g:, 'ale_r_lintr_options', 'lintr::with_defaults(object_usage_linter = NULL)')

function! ale_linters#r#lintr#GetCommand(buffer) abort
    return ale#path#BufferCdString(a:buffer)
    \   . 'Rscript -e ' . ale#Escape('lintr::lint(commandArgs(TRUE)[1], eval(parse(text = commandArgs(TRUE)[2])))') . ' %t' . ' ' . ale#Escape(ale#Var(a:buffer, 'r_lintr_options'))
endfunction

call ale#linter#Define('r', {
\   'name': 'lintr',
\   'executable': 'Rscript',
\   'command_callback': 'ale_linters#r#lintr#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'output_stream': 'both',
\})
