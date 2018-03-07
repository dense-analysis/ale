" Author: tokida https://rouger.info
" Description: textlint, a proofreading tool (https://textlint.github.io/)

function! ale_linters#markdown#textlint#GetCommand(buffer) abort
    let l:cmd_path = ale#path#FindNearestFile(a:buffer, '.textlintrc')

    if !empty(l:cmd_path)
        return 'textlint'
        \    . ' -c '
        \    . l:cmd_path
        \     . ' -f json %t'
    endif

    return ''
endfunction


call ale#linter#Define('markdown', {
\   'name': 'textlint',
\   'executable': 'textlint',
\   'command_callback': 'ale_linters#markdown#textlint#GetCommand',
\   'callback': 'ale#handlers#textlint#HandleTextlintOutput',
\})
