" Author: KabbAmine - https://github.com/KabbAmine, Ben Falconer
" <ben@falconers.me.uk>

function! ale_linters#scss#sasslint#GetCommand(buffer) abort
    let l:config = ale#Var(a:buffer, 'scss_config_file')

    return ale#path#BufferCdString(a:buffer)
    \   . ale#Escape('sass-lint')
    \   . ' -v'
    \   . ' -q'
    \   . (!empty(l:config) ? ' -c ' . l:config : '')
    \   . ' -f compact'
    \   . ' %t'
endfunction

call ale#linter#Define('scss', {
\   'name': 'sasslint',
\   'executable': 'sass-lint',
\   'command_callback': 'ale_linters#scss#sasslint#GetCommand',
\   'callback': 'ale#handlers#css#HandleCSSLintFormat',
\})
