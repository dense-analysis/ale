" Author: medains <https://github.com/medains>
" Description: phpmd for PHP files

" Set to change the ruleset
let g:ale_php_phpmd_ruleset = get(g:, 'ale_php_phpmd_ruleset', 'cleancode,codesize,controversial,design,naming,unusedcode')

function! ale_linters#php#phpmd#GetCommand(buffer) abort
    return 'phpmd %s text '
    \   . ale#Var(a:buffer, 'php_phpmd_ruleset')
    \   . ' --ignore-violations-on-exit %t'
endfunction

call ale#linter#Define('php', {
\   'name': 'phpmd',
\   'executable': 'phpmd',
\   'command_callback': 'ale_linters#php#phpmd#GetCommand',
\   'callback': 'ale#handlers#php#StaticAnalyzerHandle',
\})
