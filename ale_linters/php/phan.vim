" Author: diegoholiveira <https://github.com/diegoholiveira>
" Description: static analyzer for PHP

" Define the minimum severity
let g:ale_php_phan_minimum_severity = get(g:, 'ale_php_phan_minimum_severity', 0)

function! ale_linters#php#phan#GetCommand(buffer) abort
    return 'phan -y '
    \   . ale#Var(a:buffer, 'php_phan_minimum_severity')
    \   . ' %s'
endfunction

call ale#linter#Define('php', {
\   'name': 'phan',
\   'executable': 'phan',
\   'command_callback': 'ale_linters#php#phan#GetCommand',
\   'callback': 'ale#handlers#php#StaticAnalyzerHandle',
\})
